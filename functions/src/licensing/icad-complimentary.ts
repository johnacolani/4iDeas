import {HttpsError} from "firebase-functions/v2/https";
import {COL, db, FieldValue} from "../core";
import {
  ALL_PLATFORMS_DEVICE_LIMIT,
  getLicensePlanPolicy,
  isDevicePlatform,
  isLicensePlan,
  type DevicePlatform,
  type LicenseAccessScope,
  type LicensePlan,
} from "./license-policy";
import {licenseIdForOwner, type LicenseRecord} from "./license-store";
import {
  giftIdForEmail,
  giftOwnerUid,
  normalizeGiftEmail,
} from "./icad-complimentary-policy";

type GiftGrant = {
  email: string;
  status: "pending" | "claimed" | "cancelled";
  plan: LicensePlan;
  primaryPlatform: DevicePlatform;
  accessScope: LicenseAccessScope;
  grantedByUid: string;
  grantedByEmail: string | null;
  claimedByIcadUid?: string;
  createdAt?: unknown;
  updatedAt?: unknown;
};

/**
 * Admin authorizes one verified email address, NOT an arbitrary client UID.
 * A 4iDeas website registration is neither requested nor created.
 */
export async function reserveIcadComplimentaryGrant(params: {
  email: string;
  plan: LicensePlan;
  primaryPlatform: DevicePlatform;
  accessScope: LicenseAccessScope;
  grantedByUid: string;
  grantedByEmail: string | null;
}): Promise<string> {
  let email: string;
  try {
    email = normalizeGiftEmail(params.email);
  } catch {
    throw new HttpsError("invalid-argument", "A valid customer email is required.");
  }
  const grantId = giftIdForEmail(email);
  const ref = db.collection(COL.icadComplimentaryGrants).doc(grantId);
  const audit = db.collection(COL.licenseAudit).doc();
  await db.runTransaction(async (tx) => {
    const existing = await tx.get(ref);
    const current = existing.data() as GiftGrant | undefined;
    if (current?.status === "claimed") {
      throw new HttpsError(
        "already-exists",
        "A complimentary 4iCAD license was already claimed for this email. Use the existing license controls."
      );
    }
    const now = FieldValue.serverTimestamp();
    tx.set(ref, {
      email,
      plan: params.plan,
      primaryPlatform: params.primaryPlatform,
      accessScope: params.accessScope,
      status: "pending",
      grantedByUid: params.grantedByUid,
      grantedByEmail: params.grantedByEmail,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    } satisfies GiftGrant);
    tx.set(audit, {
      action: existing.exists ? "icad_gift_updated" : "icad_gift_reserved",
      grantId,
      ownerEmail: email,
      plan: params.plan,
      primaryPlatform: params.primaryPlatform,
      accessScope: params.accessScope,
      grantedByUid: params.grantedByUid,
      grantedByEmail: params.grantedByEmail,
      createdAt: now,
    });
  });
  return grantId;
}

/**
 * Called ONLY after the bridge has verified the short-lived 4iCAD Firebase
 * ID token and its verified email claim. Claim + license are one transaction;
 * the request cannot choose another UID or email and cannot reclaim a gift
 * after an administrator suspends or revokes the license.
 */
export async function claimIcadComplimentaryGrant(
  icadUid: string,
  verifiedEmail: string
): Promise<string | null> {
  const email = normalizeGiftEmail(verifiedEmail);
  const grantRef = db.collection(COL.icadComplimentaryGrants)
    .doc(giftIdForEmail(email));
  const ownerUid = giftOwnerUid(icadUid);
  const licenseRef = db.collection(COL.licenses).doc(licenseIdForOwner(ownerUid));
  const auditRef = db.collection(COL.licenseAudit).doc();

  return db.runTransaction(async (tx) => {
    const [grantSnap, licenseSnap] = await Promise.all([
      tx.get(grantRef),
      tx.get(licenseRef),
    ]);
    if (!grantSnap.exists) return null;
    const gift = grantSnap.data() as GiftGrant;
    if (gift.email !== email) return null;
    if (gift.status === "claimed") {
      // Never create a replacement or re-enable a revoked gift.
      return gift.claimedByIcadUid === icadUid && licenseSnap.exists
        ? ownerUid : null;
    }
    if (gift.status !== "pending") return null;
    if (!isLicensePlan(gift.plan) || !isDevicePlatform(gift.primaryPlatform) ||
        !["standard", "all_platforms"].includes(gift.accessScope)) {
      throw new HttpsError("failed-precondition", "Invalid reserved license.");
    }
    const now = FieldValue.serverTimestamp();
    if (!licenseSnap.exists) {
      const policy = getLicensePlanPolicy(gift.plan);
      const allPlatforms = gift.accessScope === "all_platforms";
      const limit = ALL_PLATFORMS_DEVICE_LIMIT;
      const license: LicenseRecord = {
        ownerUid,
        ownerEmail: email,
        plan: gift.plan,
        accessScope: gift.accessScope,
        primaryPlatform: gift.primaryPlatform,
        status: "active",
        source: "admin_complimentary_icad",
        primaryDeviceLimit: allPlatforms ? limit : policy.primaryDeviceLimit,
        bonusOtherPlatformLimit: allPlatforms ? limit : policy.bonusOtherPlatformLimit,
        totalDeviceLimit: allPlatforms ? limit : policy.totalDeviceLimit,
        activePrimaryDevices: 0,
        activeBonusDevices: 0,
        createdAt: now,
        updatedAt: now,
      };
      tx.create(licenseRef, license);
    } else {
      const existing = licenseSnap.data() as LicenseRecord;
      if (existing.ownerUid !== ownerUid ||
          existing.source !== "admin_complimentary_icad") {
        throw new HttpsError("failed-precondition",
          "Another license already occupies this 4iCAD identity.");
      }
      // Preserve existing activation counts and active/suspended/revoked state.
    }
    tx.update(grantRef, {
      status: "claimed",
      claimedByIcadUid: icadUid,
      claimedAt: now,
      updatedAt: now,
    });
    tx.set(auditRef, {
      action: "icad_gift_claimed",
      grantId: grantRef.id,
      licenseId: licenseRef.id,
      ownerUid,
      ownerEmail: email,
      createdAt: now,
    });
    return ownerUid;
  });
}

/** Only a website administrator can cancel a gift that has not been claimed. */
export async function cancelPendingIcadGrant(params: {
  email: string;
  adminUid: string;
  adminEmail: string | null;
}): Promise<void> {
  let email: string;
  try {
    email = normalizeGiftEmail(params.email);
  } catch {
    throw new HttpsError("invalid-argument", "A valid customer email is required.");
  }
  const ref = db.collection(COL.icadComplimentaryGrants)
    .doc(giftIdForEmail(email));
  const auditRef = db.collection(COL.licenseAudit).doc();
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const grant = snap.data() as GiftGrant | undefined;
    if (!grant || grant.email !== email) {
      throw new HttpsError("not-found", "Pending gift was not found.");
    }
    if (grant.status !== "pending") {
      throw new HttpsError("failed-precondition",
        "Only unclaimed gifts can be cancelled. Revoke claimed licenses from the license list.");
    }
    const now = FieldValue.serverTimestamp();
    tx.update(ref, {
      status: "cancelled",
      cancelledByUid: params.adminUid,
      cancelledAt: now,
      updatedAt: now,
    });
    tx.set(auditRef, {
      action: "icad_gift_cancelled",
      grantId: ref.id,
      ownerEmail: email,
      changedByUid: params.adminUid,
      changedByEmail: params.adminEmail,
      createdAt: now,
    });
  });
}
