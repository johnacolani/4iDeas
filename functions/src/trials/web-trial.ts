import {onCall, onRequest, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {Timestamp} from "firebase-admin/firestore";
import {
  COL,
  FieldValue,
  PRODUCT_KEY,
  WEB_TRIAL_SIGNING_KEY,
  db,
  hasEntitlement,
  requireAuth,
} from "../core";
import {
  OWNER_TOKEN_TTL_MS,
  TRIAL_WINDOW_MS,
  buildLaunchUrl,
  signTrialToken,
  trialWindow,
  verifyTrialToken,
} from "./trial-policy";

/**
 * 48-hour trial access to the 4iCAD web app.
 *
 * The web app lives in a different Firebase project, so it cannot read this
 * project's entitlements or auth state. The bridge is a signed bearer token:
 * `startWebTrial` mints one for a signed-in visitor and returns the launch URL
 * with the token attached; the web app presents that token to `verifyWebTrial`
 * on load, and periodically thereafter, to learn whether it may keep running.
 *
 * The clock is anchored server-side to the Firebase uid, so clearing browser
 * storage, using a different browser, or signing out and back in does not
 * restart it. Creating a second account does — that is the honest limit of an
 * account-bound trial, and it is why the anchor is the uid rather than a device.
 */

/** Used only if `products/{key}` carries no `webAppUrl` yet. */
const FALLBACK_WEB_APP_URL = "https://icad-75d53.web.app";

/**
 * Origins allowed to call the verification endpoint from a browser.
 *
 * The token, not the origin, is the credential — this list only stops an
 * unrelated site from quietly probing the endpoint with someone's token from
 * inside their session.
 */
const VERIFY_ALLOWED_ORIGINS = [
  "https://icad-75d53.web.app",
  "https://icad-75d53.firebaseapp.com",
  "https://4ideasapp.com",
  /^http:\/\/localhost:\d+$/,
];

interface TrialDoc {
  startedAt?: Timestamp;
  revoked?: boolean;
}

/** Reads the configured web-app URL. Server-side only, never client-supplied. */
async function webAppUrl(productKey: string): Promise<string> {
  const snap = await db.collection(COL.products).doc(productKey).get();
  const configured = (snap.data()?.webAppUrl as string | undefined)?.trim();
  return configured && configured.length > 0 ? configured : FALLBACK_WEB_APP_URL;
}

/**
 * Starts — or resumes — the caller's web-app trial and returns a launch URL.
 *
 * Idempotent by design: the first call writes `startedAt`, every later call
 * reads it back. A visitor who launches the web app ten times still gets one
 * 48-hour window.
 *
 * Owners skip the trial entirely; they have bought the product, so the token
 * they receive is not on a countdown.
 */
export const startWebTrial = onCall(
  {region: "us-central1", secrets: [WEB_TRIAL_SIGNING_KEY]},
  async (req) => {
    const {uid, email} = requireAuth(req);
    const productKey = String(req.data?.productKey ?? PRODUCT_KEY);
    if (productKey !== PRODUCT_KEY) {
      throw new HttpsError("invalid-argument", "Unknown product.");
    }

    const now = Date.now();
    const secret = WEB_TRIAL_SIGNING_KEY.value();
    const target = await webAppUrl(productKey);

    // Owning the product outranks any trial state, including an elapsed one.
    if (await hasEntitlement(uid, productKey)) {
      const exp = Math.floor((now + OWNER_TOKEN_TTL_MS) / 1000);
      const token = signTrialToken(
        {v: 1, kind: "owner", uid, productKey, iat: Math.floor(now / 1000), exp},
        secret
      );
      return {
        status: "owned",
        launchUrl: buildLaunchUrl(target, token),
        startedAt: null,
        expiresAt: null,
        remainingMs: null,
      };
    }

    const ref = db.collection(COL.webTrials).doc(uid);

    // The transaction is what makes the anchor tamper-proof against races: two
    // simultaneous launches cannot each write a fresh `startedAt`.
    const startedAtMs = await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);
      const existing = snap.data() as TrialDoc | undefined;
      const started = existing?.startedAt?.toMillis();

      if (started !== undefined) {
        tx.set(
          ref,
          {
            lastLaunchedAt: FieldValue.serverTimestamp(),
            launchCount: FieldValue.increment(1),
          },
          {merge: true}
        );
        return started;
      }

      // Timestamp.now() is the server clock. serverTimestamp() cannot be used
      // here because the same call has to return the window to the caller, and
      // a sentinel is not readable until it has been written.
      const startAt = Timestamp.fromMillis(now);
      tx.set(
        ref,
        {
          uid,
          email: email ?? null,
          productKey,
          startedAt: startAt,
          expiresAt: Timestamp.fromMillis(now + TRIAL_WINDOW_MS),
          windowMs: TRIAL_WINDOW_MS,
          launchCount: 1,
          lastLaunchedAt: FieldValue.serverTimestamp(),
          createdAt: FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      return now;
    });

    const window = trialWindow(startedAtMs, now);
    const revoked = (await ref.get()).data()?.revoked === true;

    if (window.expired || revoked) {
      logger.info("web trial refused", {uid, revoked, expired: window.expired});
      return {
        status: "expired",
        launchUrl: null,
        startedAt: window.startedAtMs,
        expiresAt: window.expiresAtMs,
        remainingMs: 0,
      };
    }

    // The token can never outlive the window it represents.
    const token = signTrialToken(
      {
        v: 1,
        kind: "trial",
        uid,
        productKey,
        iat: Math.floor(now / 1000),
        exp: Math.floor(window.expiresAtMs / 1000),
      },
      secret
    );

    logger.info("web trial launched", {uid, remainingMs: window.remainingMs});
    return {
      status: "active",
      launchUrl: buildLaunchUrl(target, token),
      startedAt: window.startedAtMs,
      expiresAt: window.expiresAtMs,
      remainingMs: window.remainingMs,
    };
  }
);

/**
 * Verification endpoint for the 4iCAD web app.
 *
 * Plain HTTPS rather than a callable, because the calling app belongs to a
 * different Firebase project and has no credentials here. The token is the
 * whole credential, so this endpoint reveals nothing beyond whether it is
 * currently good and when it lapses.
 *
 * Signature and expiry are checked first, then live Firestore state, so a
 * revoked trial or a removed entitlement stops access on the next check rather
 * than at token expiry.
 *
 * GET /verifyWebTrial?token=...   or   POST {"token": "..."}
 */
export const verifyWebTrial = onRequest(
  {region: "us-central1", secrets: [WEB_TRIAL_SIGNING_KEY], cors: VERIFY_ALLOWED_ORIGINS},
  async (req, res) => {
    if (req.method !== "GET" && req.method !== "POST") {
      res.status(405).json({valid: false, reason: "method_not_allowed"});
      return;
    }

    const token = String(
      (req.method === "GET" ? req.query?.token : req.body?.token) ?? ""
    );
    if (!token) {
      res.status(400).json({valid: false, reason: "malformed"});
      return;
    }

    const now = Date.now();
    const check = verifyTrialToken(token, WEB_TRIAL_SIGNING_KEY.value(), now);
    if (!check.valid) {
      // 200, not 401: this is a legitimate answer to a legitimate question, and
      // the web app should render "trial ended" rather than treat it as a fault.
      res.status(200).json({valid: false, reason: check.reason});
      return;
    }

    const {uid, kind, productKey} = check.payload;

    if (kind === "owner") {
      const owns = await hasEntitlement(uid, productKey);
      res.status(200).json(
        owns ?
          {valid: true, access: "owner", uid, expiresAt: check.payload.exp * 1000, remainingMs: null} :
          {valid: false, reason: "unknown_user"}
      );
      return;
    }

    // A trial holder who has since bought the product keeps access regardless
    // of the window.
    if (await hasEntitlement(uid, productKey)) {
      res.status(200).json({
        valid: true,
        access: "owner",
        uid,
        expiresAt: null,
        remainingMs: null,
      });
      return;
    }

    const snap = await db.collection(COL.webTrials).doc(uid).get();
    const doc = snap.data() as TrialDoc | undefined;
    const startedAt = doc?.startedAt?.toMillis();
    if (!snap.exists || startedAt === undefined || doc?.revoked === true) {
      res.status(200).json({valid: false, reason: "unknown_user"});
      return;
    }

    const window = trialWindow(startedAt, now);
    if (window.expired) {
      res.status(200).json({valid: false, reason: "trial_expired", expiresAt: window.expiresAtMs});
      return;
    }

    res.status(200).json({
      valid: true,
      access: "trial",
      uid,
      expiresAt: window.expiresAtMs,
      remainingMs: window.remainingMs,
    });
  }
);
