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
