import {onCall, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {auth, db, FieldValue, LEGACY_ADMIN_EMAILS, requireAdmin, requireAuth} from "../core";

const ADMIN_AUDIT = "admin_claim_audit";

async function grant(targetUid: string, targetEmail: string | null, byUid: string, byEmail: string | null, admin: boolean) {
  const user = await auth.getUser(targetUid);
  const claims = {...(user.customClaims ?? {})};
  if (admin) {
    claims.admin = true;
  } else {
    delete claims.admin;
  }
  await auth.setCustomUserClaims(targetUid, claims);
  // Force existing sessions to pick the change up on next token refresh.
  await auth.revokeRefreshTokens(targetUid);
  await db.collection(ADMIN_AUDIT).add({
    targetUid,
    targetEmail: targetEmail ?? user.email ?? null,
    admin,
    byUid,
    byEmail,
    at: FieldValue.serverTimestamp(),
  });
  logger.info("admin claim updated", {targetUid, admin, byUid});
}

/**
 * Step 1 of the migration. A user whose verified token email is on the legacy
 * allowlist may mint their OWN `admin: true` claim exactly once. This is the
 * bridge from email-based authorization to claim-based authorization, and it is
 * the reason the existing administrator cannot be locked out.
 *
 * It grants only to the caller — never to an arbitrary uid — so it cannot be
 * used to escalate anyone else.
 *
 * Delete this function once every administrator holds the claim.
 */
export const bootstrapAdminClaim = onCall({region: "us-central1"}, async (req) => {
  const {uid, email} = requireAuth(req);
  const normalized = email?.toLowerCase().trim() ?? "";
  if (!normalized || !LEGACY_ADMIN_EMAILS.includes(normalized)) {
    throw new HttpsError("permission-denied", "This account is not on the administrator allowlist.");
  }
  if (req.auth?.token.admin === true) {
    return {alreadyAdmin: true, uid, email: normalized};
  }
  await grant(uid, normalized, uid, normalized, true);
  return {
    granted: true,
    uid,
    email: normalized,
    note: "Sign out and back in (or refresh your ID token) for the claim to take effect.",
  };
});

/**
 * Step 2 onwards. An already-verified admin grants or revokes admin on another
 * account, looked up by email. Requires the caller to pass `requireAdmin`, which
 * reads the verified token — never a browser-supplied flag.
 */
export const setAdminClaim = onCall({region: "us-central1"}, async (req) => {
  const caller = requireAdmin(req);
  const targetEmail = String(req.data?.email ?? "").toLowerCase().trim();
  const admin = req.data?.admin === true;
  if (!targetEmail) {
    throw new HttpsError("invalid-argument", "An email address is required.");
  }

  let target;
  try {
    target = await auth.getUserByEmail(targetEmail);
  } catch {
    throw new HttpsError("not-found", `No account exists for ${targetEmail}.`);
  }

  // Guard against an admin removing their own access and stranding the project.
  if (!admin && target.uid === caller.uid) {
    throw new HttpsError("failed-precondition", "You cannot remove your own administrator access.");
  }

  await grant(target.uid, targetEmail, caller.uid, caller.email, admin);
  return {ok: true, email: targetEmail, admin};
});

/** Lets the client and the migration check report who actually holds the claim. */
export const listAdmins = onCall({region: "us-central1"}, async (req) => {
  requireAdmin(req);
  const admins: Array<{uid: string; email: string | null; hasClaim: boolean}> = [];
  let pageToken: string | undefined;
  do {
    const page = await auth.listUsers(1000, pageToken);
    for (const u of page.users) {
      const hasClaim = u.customClaims?.admin === true;
      const legacy = !!u.email && LEGACY_ADMIN_EMAILS.includes(u.email.toLowerCase());
      if (hasClaim || legacy) {
        admins.push({uid: u.uid, email: u.email ?? null, hasClaim});
      }
    }
    pageToken = page.pageToken;
  } while (pageToken);
  return {admins, legacyAllowlist: LEGACY_ADMIN_EMAILS};
});
