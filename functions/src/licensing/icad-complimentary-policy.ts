import {createHash} from "node:crypto";

/** Normalize at issue AND redemption; never trust user-supplied UIDs. */
export function normalizeGiftEmail(value: string): string {
  const email = value.trim().toLowerCase();
  if (!email || email.length > 320 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new Error("A valid customer email is required.");
  }
  return email;
}

/** Private Firestore document id (never use the raw email as a path). */
export function giftIdForEmail(email: string): string {
  return createHash("sha256").update(normalizeGiftEmail(email), "utf8")
    .digest("hex");
}

/** Separate namespace from website and production StoreKit license owners. */
export function giftOwnerUid(icadUid: string): string {
  const uid = icadUid.trim();
  if (!uid || uid.length > 128 || uid.includes("/")) {
    throw new Error("Invalid 4iCAD account identity.");
  }
  return `icad-gift:${uid}`;
}

export type GiftClaimDecision = "new" | "existing" | "none";

/**
 * Only a signed, verified 4iCAD email is accepted by the caller.
 * A claimed gift belongs exclusively to its first verified 4iCAD UID.
 */
export function decideGiftClaim(
  gift: {
    email: string;
    status: string;
    claimedByIcadUid?: string;
  } | undefined,
  verifiedEmail: string,
  icadUid: string,
  licenseExists: boolean
): GiftClaimDecision {
  if (!gift || gift.email !== normalizeGiftEmail(verifiedEmail)) return "none";
  if (gift.status === "pending") return "new";
  if (gift.status === "claimed" &&
      gift.claimedByIcadUid === icadUid && licenseExists) {
    return "existing";
  }
  return "none";
}
