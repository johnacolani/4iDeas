import {createHmac, timingSafeEqual} from "node:crypto";

/**
 * Pure trial policy: the 48-hour window arithmetic and the access-token format.
 *
 * Deliberately free of side effects — no Admin SDK, no Firestore, no secrets
 * read at import time — so every rule here is unit testable directly, the same
 * way `auth-guards` is. The callables in `web-trial.ts` supply the clock, the
 * signing key and the stored start time; this module decides what they mean.
 */

/** How long a web-app trial lasts, from first launch. */
export const TRIAL_WINDOW_MS = 48 * 60 * 60 * 1000;

/**
 * How long an owner's token stays valid before the web app must ask again.
 *
 * Owners are not on a clock, but the token is still short-lived so that a
 * refund or a revoked entitlement takes effect within days rather than never.
 */
export const OWNER_TOKEN_TTL_MS = 7 * 24 * 60 * 60 * 1000;

/** Why access was refused. Returned to the caller; safe to show a visitor. */
export type TrialDenial =
  | "malformed"
  | "bad_signature"
  | "token_expired"
  | "trial_expired"
  | "unknown_user";

/** What kind of access a token grants. */
export type TrialAccessKind = "owner" | "trial";

export interface TrialTokenPayload {
  /** Format version, so the web app can reject a shape it does not understand. */
  v: 1;
  kind: TrialAccessKind;
  uid: string;
  productKey: string;
  /** Issued-at, epoch seconds. */
  iat: number;
  /** Hard expiry, epoch seconds. For a trial this is the end of the 48 hours. */
  exp: number;
}

export interface TrialWindow {
  startedAtMs: number;
  expiresAtMs: number;
  /** Never negative — an elapsed trial reports zero, not a negative countdown. */
  remainingMs: number;
  expired: boolean;
}

/**
 * Resolves a stored trial start against the current clock.
 *
 * The window is anchored to the first launch, so re-launching does not extend
 * it and signing out does not reset it: the anchor lives on the server, keyed
 * by uid.
 */
export function trialWindow(
  startedAtMs: number,
  nowMs: number,
  windowMs: number = TRIAL_WINDOW_MS
): TrialWindow {
  const expiresAtMs = startedAtMs + windowMs;
  const remainingMs = Math.max(0, expiresAtMs - nowMs);
  return {startedAtMs, expiresAtMs, remainingMs, expired: remainingMs <= 0};
}

function base64UrlEncode(input: string): string {
  return Buffer.from(input, "utf8")
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

function base64UrlDecode(input: string): string {
  return Buffer.from(input.replace(/-/g, "+").replace(/_/g, "/"), "base64").toString("utf8");
}

function signature(body: string, secret: string): string {
  return createHmac("sha256", secret).update(body).digest("base64url");
}

/**
 * Mints a bearer token the 4iCAD web app can present back to `verifyWebTrial`.
 *
 * HMAC rather than asymmetric signing because only our own backend verifies it:
 * the web app never holds the key, it calls the verification endpoint. That
 * matters — the web app is a browser bundle, so any key shipped to it would be
 * readable by anyone who opens devtools.
 */
export function signTrialToken(payload: TrialTokenPayload, secret: string): string {
  if (!secret) throw new Error("A signing secret is required.");
  const body = base64UrlEncode(JSON.stringify(payload));
  return `${body}.${signature(body, secret)}`;
}

export type TrialTokenCheck =
  | {valid: true; payload: TrialTokenPayload}
  | {valid: false; reason: TrialDenial};

/**
 * Verifies signature and expiry.
 *
 * The signature is checked before the payload is trusted for anything, and the
 * comparison is constant time so the endpoint cannot be used as an oracle to
 * discover a valid signature byte by byte.
 *
 * A passing token proves only that we issued it and that it has not lapsed.
 * Current entitlement and the live trial window are re-read from Firestore by
 * the caller, so a refund or a revoked trial takes effect immediately rather
 * than at token expiry.
 */
export function verifyTrialToken(
  token: string,
  secret: string,
  nowMs: number
): TrialTokenCheck {
  if (!secret) throw new Error("A signing secret is required.");
  const parts = String(token ?? "").split(".");
  if (parts.length !== 2 || !parts[0] || !parts[1]) {
    return {valid: false, reason: "malformed"};
  }
  const [body, provided] = parts;

  const expected = signature(body, secret);
  // timingSafeEqual throws on a length mismatch, which is itself a leak-free
  // signal that the token is wrong.
  const a = Buffer.from(provided);
  const b = Buffer.from(expected);
  if (a.length !== b.length || !timingSafeEqual(a, b)) {
    return {valid: false, reason: "bad_signature"};
  }

  let payload: TrialTokenPayload;
  try {
    payload = JSON.parse(base64UrlDecode(body)) as TrialTokenPayload;
  } catch {
    return {valid: false, reason: "malformed"};
  }

  if (payload?.v !== 1 || !payload.uid || !payload.exp || !payload.kind) {
    return {valid: false, reason: "malformed"};
  }
  if (payload.exp * 1000 <= nowMs) {
    return {valid: false, reason: payload.kind === "trial" ? "trial_expired" : "token_expired"};
  }
  return {valid: true, payload};
}

/**
 * Builds the launch URL the visitor is sent to.
 *
 * The base comes from server-side product config, never from the browser, so a
 * caller cannot have a valid token attached to a site of their choosing.
 */
export function buildLaunchUrl(webAppUrl: string, token: string): string {
  const url = new URL(webAppUrl);
  if (url.protocol !== "https:") {
    throw new Error("The web app URL must be https.");
  }
  url.searchParams.set("trial", token);
  return url.toString();
}
