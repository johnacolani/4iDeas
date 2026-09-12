import {createHash} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {COL, FieldValue, db} from "../core";
import type {DevicePlatform} from "./license-policy";
import {
  createOrUpdateLicense,
  getOwnerLicense,
  type LicenseRecord,
} from "./license-store";

export type NativeStoreName = "apple" | "google_play";

export interface VerifiedNativePurchase {
  store: NativeStoreName;
  externalPurchaseId: string;
  productId: string;
  platform: DevicePlatform;
  environment: string;
  orderId?: string | null;
}

export interface NativeStoreLicenseGrant {
  ownerUid: string;
  license: {
    id: string;
    data: LicenseRecord;
  };
}

function purchaseDocId(store: NativeStoreName, externalPurchaseId: string): string {
  return createHash("sha256")
    .update(`${store}:${externalPurchaseId}`, "utf8")
    .digest("hex");
}

function syntheticOwnerUid(icadUid: string): string {
  return `icad-store:${icadUid}`;
}

/** Return a previously established native-store license owner for a 4iCAD UID. */
export async function getNativeStoreOwnerUid(
  icadUid: string
): Promise<string | null> {
  const snap = await db.collection(COL.nativeStoreLicenseLinks).doc(icadUid).get();
  if (!snap.exists) return null;
  const ownerUid = String(snap.data()?.ownerUid ?? "").trim();
  return ownerUid || null;
}

/**
 * Claim verified store evidence exactly once and ensure it results in one
 * durable Individual license. The external transaction/token can never be
 * attached to a different 4iCAD account after it has been claimed.
 *
 * Raw Google Play purchase tokens are intentionally not persisted. The
 * deterministic SHA-256 document id is sufficient for replay prevention.
 */
export async function grantNativeStoreLicense(params: {
  icadUid: string;
  email: string;
  purchase: VerifiedNativePurchase;
}): Promise<NativeStoreLicenseGrant> {
  const {icadUid, email, purchase} = params;
  const purchaseId = purchaseDocId(purchase.store, purchase.externalPurchaseId);
  const purchaseRef = db.collection(COL.nativeStorePurchases).doc(purchaseId);
  const linkRef = db.collection(COL.nativeStoreLicenseLinks).doc(icadUid);

  const ownerUid = await db.runTransaction(async (tx) => {
    const [purchaseSnap, linkSnap] = await Promise.all([
      tx.get(purchaseRef),
      tx.get(linkRef),
    ]);

    if (purchaseSnap.exists) {
      const claimedIcadUid = String(purchaseSnap.data()?.icadUid ?? "").trim();
      if (claimedIcadUid && claimedIcadUid !== icadUid) {
        throw new HttpsError(
          "permission-denied",
          "This store purchase is already linked to another 4iCAD account."
        );
      }
    }

    const existingOwnerUid = String(linkSnap.data()?.ownerUid ?? "").trim();
    const resolvedOwnerUid = existingOwnerUid || syntheticOwnerUid(icadUid);
    const now = FieldValue.serverTimestamp();

    tx.set(
      purchaseRef,
      {
        store: purchase.store,
        purchaseEvidenceHash: purchaseId,
        productId: purchase.productId,
        platform: purchase.platform,
        environment: purchase.environment,
        orderId: purchase.orderId ?? null,
        icadUid,
        ownerUid: resolvedOwnerUid,
        ownerEmail: email,
        active: true,
        createdAt: purchaseSnap.data()?.createdAt ?? now,
        updatedAt: now,
      },
      {merge: true}
    );

    tx.set(
      linkRef,
      {
        icadUid,
        ownerUid: resolvedOwnerUid,
        email,
        source: "native_store",
        createdAt: linkSnap.data()?.createdAt ?? now,
        updatedAt: now,
      },
      {merge: true}
    );

    return resolvedOwnerUid;
  });

  let license = await getOwnerLicense(ownerUid);
  if (!license) {
    await createOrUpdateLicense({
      ownerUid,
      ownerEmail: email,
      plan: "individual",
      primaryPlatform: purchase.platform,
      source: purchase.store === "apple" ? "app_store" : "google_play",
      orderId: purchase.orderId ?? purchaseId,
    });
    license = await getOwnerLicense(ownerUid);
  }

  if (!license) {
    throw new HttpsError(
      "internal",
      "The verified purchase could not be converted into a 4iCAD license."
    );
  }

  await db.collection(COL.licenseAudit).add({
    action: "native_store_purchase_verified",
    licenseId: license.id,
    ownerUid,
    icadUid,
    store: purchase.store,
    productId: purchase.productId,
    platform: purchase.platform,
    environment: purchase.environment,
    orderId: purchase.orderId ?? null,
    purchaseEvidenceHash: purchaseId,
    createdAt: FieldValue.serverTimestamp(),
  });

  return {ownerUid, license};
}
