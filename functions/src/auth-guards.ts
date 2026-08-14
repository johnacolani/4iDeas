import {HttpsError, CallableRequest} from "firebase-functions/v2/https";

/**
 * Authorization guards for callable functions.
 *
 * Deliberately kept free of side effects — this module does not call
 * initializeApp() — so the guards can be unit tested directly. Every decision
 * here is made from the *verified* Firebase ID token that the callable runtime
 * has already validated; nothing the browser sends in the request body is
 * consulted.
 */

/**
 * Legacy admin allowlist, retained ONLY so the custom-claim migration cannot
 * lock the existing administrator out. Once every admin has the `admin: true`
 * claim and it is verified, this list and its uses can be deleted.
 */
export const LEGACY_ADMIN_EMAILS = ["john.ace.colani@outlook.com"];

export interface Caller {
  uid: string;
  email: string | null;
}

/** Require a signed-in caller. */
export function requireAuth(req: CallableRequest): Caller {
  if (!req.auth?.uid) {
    throw new HttpsError("unauthenticated", "Sign in to continue.");
  }
  const email = (req.auth.token.email as string | undefined) ?? null;
  return {uid: req.auth.uid, email};
}

/**
 * Require a signed-in caller whose email address Firebase reports as verified.
 *
 * Used to gate the start of a purchase. `email_verified` is a claim on the
 * verified ID token, so this cannot be spoofed by the client.
 *
 * Federated providers that assert a verified address — Google, and Apple —
 * arrive with `email_verified: true`, so those accounts pass naturally. The
 * guard therefore only stops email/password accounts that have not yet
 * completed verification.
 *
 * Deliberately NOT applied to downloads: once someone has paid, entitlement is
 * the authority for retrieving the installer. Re-checking verification there
 * would strand a legitimate buyer who later changes to an unverified address.
 */
export function requireVerifiedAuth(req: CallableRequest): Caller {
  const caller = requireAuth(req);
  if (req.auth?.token.email_verified !== true) {
    throw new HttpsError(
      "failed-precondition",
      "Verify your email address before purchasing.",
      {reason: "email_not_verified"}
    );
  }
  return caller;
}

/**
 * Require a verified admin. Accepts the `admin: true` custom claim, and — only
 * during the claim migration — the legacy email allowlist. Both are read from
 * the verified Firebase ID token, never from anything the browser sends.
 */
export function requireAdmin(req: CallableRequest): Caller {
  const caller = requireAuth(req);
  const hasClaim = req.auth?.token.admin === true;
  const legacy =
    !!caller.email && LEGACY_ADMIN_EMAILS.includes(caller.email.toLowerCase().trim());
  if (!hasClaim && !legacy) {
    throw new HttpsError("permission-denied", "Administrator access required.");
  }
  return caller;
}
