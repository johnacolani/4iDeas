import {onCall, HttpsError} from "firebase-functions/v2/https";
import {reserveIcadComplimentaryGrant} from "./icad-complimentary";
import {
  COL,
  FieldValue,
  auth,
  db,
  requireAdmin,
} from "../core";
import {
  isDevicePlatform,
  isLicensePlan,
} from "./license-policy";
import {
  createOrUpdateLicense,
  deactivateDevice,
  licenseIdForOwner,
  listOwnerDevices,
  withEffectiveLicenseLimits,
  type LicenseRecord,
} from "./license-store";

const ADMIN_LIST_LIMIT = 200;

function millis(value: unknown): number | null {
  if (
    value &&
    typeof value === "object" &&
    "toMillis" in value &&
    typeof (value as {toMillis?: unknown}).toMillis === "function"
  ) {
    return (value as {toMillis: () => number}).toMillis();
  }
  return null;
}

export const listLicenses = onCall({region: "us-central1"}, async (req) => {
  requireAdmin(req);
  const snap = await db.collection(COL.licenses).limit(ADMIN_LIST_LIMIT).get();
  return {
    licenses: snap.docs.map((doc) => {
      const data = withEffectiveLicenseLimits(doc.data() as LicenseRecord);
      return {
        id: doc.id,
        ownerUid: data.ownerUid ?? null,
        ownerEmail: data.ownerEmail ?? null,
        plan: data.plan ?? null,
        accessScope: data.accessScope ?? "standard",
        primaryPlatform: data.primaryPlatform ?? null,
        status: data.status ?? null,
        source: data.source ?? null,
        orderId: data.orderId ?? null,
        primaryDeviceLimit: data.primaryDeviceLimit ?? 0,
        bonusOtherPlatformLimit: data.bonusOtherPlatformLimit ?? 0,
        totalDeviceLimit: data.totalDeviceLimit ?? 0,
        activePrimaryDevices: data.activePrimaryDevices ?? 0,
        activeBonusDevices: data.activeBonusDevices ?? 0,
        createdAt: millis(data.createdAt),
        updatedAt: millis(data.updatedAt),
      };
    }),
  };
});

export const getLicenseDevices = onCall({region: "us-central1"}, async (req) => {
  requireAdmin(req);
  const ownerUid = String(req.data?.ownerUid ?? "").trim();
  if (!ownerUid) {
    throw new HttpsError("invalid-argument", "ownerUid is required.");
  }
  const devices = await listOwnerDevices(ownerUid);
  return {
    devices: devices.map((device) => ({
      installationId: device.installationId,
      platform: device.platform,
      bucket: device.bucket,
      deviceName: device.deviceName ?? null,
      appVersion: device.appVersion ?? null,
      active: device.active,
      activatedAt: millis(device.activatedAt),
      lastSeenAt: millis(device.lastSeenAt),
      deactivatedAt: millis(device.deactivatedAt),
    })),
  };
});

/** Only verified administrators may see email reservations awaiting 4iCAD login. */
export const listPendingIcadGifts = onCall(
  {region: "us-central1"}, async (req) => {
    requireAdmin(req);
    const snap = await db.collection(COL.icadComplimentaryGrants)
      .where("status", "==", "pending").limit(ADMIN_LIST_LIMIT).get();
    return {
      grants: snap.docs.map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          email: data.email,
          plan: data.plan,
          primaryPlatform: data.primaryPlatform,
          accessScope: data.accessScope,
          status: "pending",
          createdAt: millis(data.createdAt),
        };
      }),
    };
  }
);

export const grantComplimentaryLicense = onCall(
  {region: "us-central1"},
  async (req) => {
    const adminCaller = requireAdmin(req);
    const email = String(req.data?.email ?? "").trim().toLowerCase();
    const plan = String(req.data?.plan ?? "").trim().toLowerCase();
    const primaryPlatform = String(req.data?.primaryPlatform ?? "")
      .trim()
      .toLowerCase();
    const accessScope =
      req.data?.allPlatforms === true ? "all_platforms" : "standard";

    if (!email || !email.includes("@")) {
      throw new HttpsError("invalid-argument", "A valid customer email is required.");
    }
    if (!isLicensePlan(plan)) {
      throw new HttpsError("invalid-argument", "Unknown license plan.");
    }
    if (!isDevicePlatform(primaryPlatform)) {
      throw new HttpsError("invalid-argument", "Unsupported primary platform.");
    }

    // Explicit account target prevents cross-project UID confusion.
    // Existing callers without accountType retain the original website route.
    const accountType = String(req.data?.accountType ?? "website");
    if (accountType === "icad") {
      const grantId = await reserveIcadComplimentaryGrant({
        email,
        plan,
        primaryPlatform,
        accessScope,
        grantedByUid: adminCaller.uid,
        grantedByEmail: adminCaller.email,
      });
      return {grantId, status: "pending", accountType: "icad"};
    }
    if (accountType !== "website") {
      throw new HttpsError("invalid-argument", "Unknown customer account type.");
    }

    let customer;
    try {
      customer = await auth.getUserByEmail(email);
    } catch (error: unknown) {
      const code =
        typeof error === "object" && error !== null && "code" in error
          ? String((error as {code?: unknown}).code)
          : "";
      if (code === "auth/user-not-found") {
        throw new HttpsError("not-found",
          "No 4iDeas website account exists for this email. Select 4iCAD account to grant without a website login.");
      }
      // Never mask configuration/service/permission failures as missing users.
      throw new HttpsError("internal",
        "Firebase could not look up this customer. Try again or check server logs.");
    }

    const licenseId = await createOrUpdateLicense({
      ownerUid: customer.uid,
      ownerEmail: customer.email ?? email,
      plan,
      primaryPlatform,
      accessScope,
      source: "admin_complimentary",
    });

    await db.collection(COL.licenseAudit).add({
      action: "license_granted",
      licenseId,
      ownerUid: customer.uid,
      ownerEmail: customer.email ?? email,
      plan,
      primaryPlatform,
      accessScope,
      grantedByUid: adminCaller.uid,
      grantedByEmail: adminCaller.email,
      createdAt: FieldValue.serverTimestamp(),
    });

    return {licenseId, ownerUid: customer.uid};
  }
);

export const setLicenseStatus = onCall({region: "us-central1"}, async (req) => {
  const adminCaller = requireAdmin(req);
  const ownerUid = String(req.data?.ownerUid ?? "").trim();
  const status = String(req.data?.status ?? "").trim().toLowerCase();
  if (!ownerUid) {
    throw new HttpsError("invalid-argument", "ownerUid is required.");
  }
  if (status !== "active" && status !== "suspended" && status !== "revoked") {
    throw new HttpsError("invalid-argument", "Invalid license status.");
  }

  const licenseId = licenseIdForOwner(ownerUid);
  const ref = db.collection(COL.licenses).doc(licenseId);
  const snap = await ref.get();
  if (!snap.exists) {
    throw new HttpsError("not-found", "License not found.");
  }

  await db.runTransaction(async (tx) => {
    const current = await tx.get(ref);
    if (!current.exists) {
      throw new HttpsError("not-found", "License not found.");
    }
    const oldStatus = current.data()?.status ?? null;
    tx.update(ref, {
      status,
      updatedAt: FieldValue.serverTimestamp(),
    });
    const auditRef = db.collection(COL.licenseAudit).doc();
    tx.set(auditRef, {
      action: "license_status_changed",
      licenseId,
      ownerUid,
      oldStatus,
      newStatus: status,
      changedByUid: adminCaller.uid,
      changedByEmail: adminCaller.email,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  return {licenseId, status};
});

export const adminDeactivateDevice = onCall(
  {region: "us-central1"},
  async (req) => {
    const adminCaller = requireAdmin(req);
    const ownerUid = String(req.data?.ownerUid ?? "").trim();
    const installationId = String(req.data?.installationId ?? "").trim();
    if (!ownerUid || !installationId) {
      throw new HttpsError(
        "invalid-argument",
        "ownerUid and installationId are required."
      );
    }

    const result = await deactivateDevice(ownerUid, installationId);
    if (result.deactivated) {
      await db.collection(COL.licenseAudit).add({
        action: "device_deactivated_by_admin",
        licenseId: licenseIdForOwner(ownerUid),
        ownerUid,
        installationId,
        changedByUid: adminCaller.uid,
        changedByEmail: adminCaller.email,
        createdAt: FieldValue.serverTimestamp(),
      });
    }
    return result;
  }
);
