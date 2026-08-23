import {onCall, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import type Stripe from "stripe";
import {
  COL,
  DOWNLOADABLE_PRODUCTS,
  FieldValue,
  PRODUCT_KEY,
  STRIPE_SECRET_KEY,
  db,
  entitlementId,
  requireAuth,
  storage,
  stripeClient,
} from "../core";

/** How long an issued installer link stays valid. Deliberately short. */
const SIGNED_URL_TTL_MS = 10 * 60 * 1000;

/** Ceiling on link issuance per user per hour, so a leaked link can't be farmed. */
const MAX_ISSUES_PER_HOUR = 20;

/**
 * Confirms a purchase for the success page.
 *
 * The page passes the `session_id` Stripe put in the return URL, but that id is
 * treated only as a lookup hint — never as proof. Entitlement is read from the
 * authenticated user's own Firestore state, which only the webhook can write.
 *
 * If the webhook has not landed yet (the success redirect regularly beats it),
 * we ask Stripe directly about that session and, if it is genuinely fulfillable
 * AND belongs to this caller, report "processing" rather than failure.
 */
export const getPurchaseStatus = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    const {uid} = requireAuth(req);
    const productKey = String(req.data?.productKey ?? PRODUCT_KEY);
    const sessionId = req.data?.sessionId ? String(req.data.sessionId) : null;

    const entSnap = await db
      .collection(COL.entitlements)
      .doc(entitlementId(uid, productKey))
      .get();

    if (entSnap.exists && entSnap.data()?.active === true) {
      return {state: "entitled", productKey};
    }

    if (!sessionId) {
      return {state: "none", productKey};
    }

    // Not entitled yet. Ask Stripe whether this specific session is a real,
    // fulfillable purchase belonging to this user.
    let session: Stripe.Checkout.Session;
    try {
      session = await stripeClient().checkout.sessions.retrieve(sessionId);
    } catch {
      return {state: "none", productKey};
    }

    const owner = session.metadata?.firebaseUid ?? session.client_reference_id;
    if (owner !== uid) {
      // Someone pasted another person's session id. Reveal nothing.
      logger.warn("session ownership mismatch on status check", {uid, sessionId});
      return {state: "none", productKey};
    }

    const settled =
      session.payment_status === "paid" || session.payment_status === "no_payment_required";
    if (settled) {
      // Real purchase, webhook still in flight.
      return {state: "processing", productKey};
    }
    return {state: "unpaid", productKey};
  }
);

/**
 * Issues a short-lived, authorized link for the product's Current desktop release.
 *
 * The installer object itself is never publicly readable — Storage rules deny
 * client reads on the release prefix outright. The only way to obtain bytes is
 * through this function, which verifies entitlement against server-side state
 * first. The resulting V4 signed URL expires, so a copied link stops working.
 * It is deliberately never persisted to Firestore.
 */
export const getDownloadUrl = onCall({region: "us-central1"}, async (req) => {
  const {uid, email} = requireAuth(req);
  const productKey = String(req.data?.productKey ?? PRODUCT_KEY);
  const downloadable = DOWNLOADABLE_PRODUCTS[productKey];
  if (!downloadable) {
    throw new HttpsError("invalid-argument", "This product has no downloadable release.");
  }

  const entSnap = await db
    .collection(COL.entitlements)
    .doc(entitlementId(uid, productKey))
    .get();
  if (!entSnap.exists || entSnap.data()?.active !== true) {
    throw new HttpsError("permission-denied", "You do not own this product.");
  }

  // Simple per-user rate limit on issuance.
  const since = new Date(Date.now() - 60 * 60 * 1000);
  const recent = await db
    .collection("download_audit")
    .where("uid", "==", uid)
    .where("issuedAt", ">=", since)
    .count()
    .get();
  if (recent.data().count >= MAX_ISSUES_PER_HOUR) {
    throw new HttpsError("resource-exhausted", "Too many download requests. Try again later.");
  }

  const releaseQuery = await db
    .collection(COL.releases)
    .where("productKey", "==", productKey)
    .where("platform", "==", downloadable.platform)
    .where("isCurrent", "==", true)
    .limit(1)
    .get();

  if (releaseQuery.empty) {
    throw new HttpsError(
      "not-found",
      `No ${downloadable.platform} release has been published yet.`
    );
  }

  const release = releaseQuery.docs[0];
  const data = release.data();
  const storagePath = data.storagePath as string | undefined;
  if (!storagePath) {
    throw new HttpsError("failed-precondition", "The current release has no installer file.");
  }

  const file = storage.bucket().file(storagePath);
  const [exists] = await file.exists();
  if (!exists) {
    logger.error("release object missing from storage", {storagePath, releaseId: release.id});
    throw new HttpsError("not-found", "The installer file is unavailable.");
  }

  const expires = Date.now() + SIGNED_URL_TTL_MS;
  const [url] = await file.getSignedUrl({
    version: "v4",
    action: "read",
    expires,
    promptSaveAs: (data.originalFileName as string) ?? downloadable.defaultFileName,
  });

  await db.collection("download_audit").add({
    uid,
    email,
    productKey,
    platform: downloadable.platform,
    releaseId: release.id,
    version: data.version ?? null,
    storagePath,
    issuedAt: FieldValue.serverTimestamp(),
    expiresAt: new Date(expires),
  });

  logger.info("download link issued", {uid, releaseId: release.id});

  return {
    url,
    expiresAt: expires,
    version: data.version ?? null,
    fileName: data.originalFileName ?? null,
    fileSizeBytes: data.fileSizeBytes ?? null,
    sha256: data.sha256 ?? null,
    releaseNotes: data.releaseNotes ?? null,
  };
});
