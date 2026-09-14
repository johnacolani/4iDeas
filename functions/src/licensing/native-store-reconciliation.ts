import {createHash} from "node:crypto";
import {COL, FieldValue, db} from "../core";
import {
  licenseIdForOwner,
  type LicenseDeviceRecord,
  type LicenseRecord,
} from "./license-store";
import type {NativeStoreName} from "./native-store-license";
import {
  shouldReactivateNativeLicense,
  shouldRevokeNativeLicense,
} from "./native-store-reconciliation-policy";

export interface NativeStorePurchaseEvidence {
  id: string;
  data: {
    store: NativeStoreName;
    productId: string;
    platform: string;
    environment: string;
    testPurchase?: boolean;
    orderId?: string | null;
    icadUid: string;
    ownerUid: string;
    ownerEmail?: string | null;
    active: boolean;
    [key: string]: unknown;
  };
}

export interface NativeStoreReconciliationResult {
  found: boolean;
  purchaseActive: boolean | null;
  licenseAction:
    | "revoked"
    | "reactivated"
    | "preserved_non_native_license"
    | "unchanged"
    | "missing_license";
  ownerUid: string | null;
  licenseId: string | null;
  deactivatedDevices: number;
}

export function nativeStorePurchaseEvidenceId(
  store: NativeStoreName,
  externalPurchaseId: string
): string {
  return createHash("sha256")
    .update(`${store}:${externalPurchaseId}`, "utf8")
    .digest("hex");
}

export async function getNativeStorePurchaseEvidence(
  store: NativeStoreName,
  externalPurchaseId: string
): Promise<NativeStorePurchaseEvidence | null> {
  const id = nativeStorePurchaseEvidenceId(store, externalPurchaseId);
  const snap = await db.collection(COL.nativeStorePurchases).doc(id).get();
  if (!snap.exists) return null;
  const data = snap.data() as NativeStorePurchaseEvidence["data"];
  if (data.store !== store) return null;
  return {id, data};
}

/**
 * Apply an authoritative store state to existing native purchase evidence.
 *
 * A refunded/revoked native purchase only revokes a license that was itself
 * created from a native store purchase and has no other active native purchase.
 * If the native purchase was attached to an independent Stripe/admin license,
 * that independent entitlement is preserved. Refund reversal only reactivates a
 * license when this exact purchase previously caused the automatic revocation,
 * so a store event can never undo an unrelated admin suspension/revocation.
 */
export async function reconcileNativeStorePurchase(params: {
  store: NativeStoreName;
  externalPurchaseId: string;
  authoritativeActive: boolean;
  notificationType: string;
  notificationUuid?: string | null;
  authoritativeEnvironment?: string | null;
  revocationDate?: number | null;
  revocationReason?: string | null;
  revocationType?: string | null;
  revocationPercentage?: number | null;
}): Promise<NativeStoreReconciliationResult> {
  const purchaseId = nativeStorePurchaseEvidenceId(
    params.store,
    params.externalPurchaseId
  );
  const purchaseRef = db.collection(COL.nativeStorePurchases).doc(purchaseId);

  return db.runTransaction(async (tx) => {
    const purchaseSnap = await tx.get(purchaseRef);
    if (!purchaseSnap.exists) {
      return {
        found: false,
        purchaseActive: null,
        licenseAction: "unchanged" as const,
        ownerUid: null,
        licenseId: null,
        deactivatedDevices: 0,
      };
    }

    const purchase = purchaseSnap.data() as NativeStorePurchaseEvidence["data"];
    if (purchase.store !== params.store) {
      return {
        found: false,
        purchaseActive: null,
        licenseAction: "unchanged" as const,
        ownerUid: null,
        licenseId: null,
        deactivatedDevices: 0,
      };
    }

    const ownerUid = String(purchase.ownerUid ?? "").trim();
    if (!ownerUid) {
      throw new Error("Native store purchase evidence has no license owner.");
    }

    const licenseId = licenseIdForOwner(ownerUid);
    const licenseRef = db.collection(COL.licenses).doc(licenseId);
    const licenseSnap = await tx.get(licenseRef);

    const ownerPurchasesSnap = await tx.get(
      db.collection(COL.nativeStorePurchases).where("ownerUid", "==", ownerUid)
    );
    const remainingActiveNativePurchases = ownerPurchasesSnap.docs.filter((doc) => {
      if (doc.id === purchaseId) return false;
      const row = doc.data();
      return row.active === true;
    }).length;

    const license = licenseSnap.exists
      ? (licenseSnap.data() as LicenseRecord & {
          nativeStoreRevokedPurchaseEvidenceHash?: string | null;
        })
      : null;

    const shouldRevoke =
      !params.authoritativeActive &&
      license !== null &&
      shouldRevokeNativeLicense({
        source: license.source,
        remainingActiveNativePurchases,
      });

    let activeDeviceDocs: Array<{
      ref: FirebaseFirestore.DocumentReference;
      data: LicenseDeviceRecord;
    }> = [];
    if (shouldRevoke) {
      const deviceSnap = await tx.get(
        db.collection(COL.licenseDevices).where("licenseId", "==", licenseId)
      );
      activeDeviceDocs = deviceSnap.docs
        .map((doc) => ({
          ref: doc.ref,
          data: doc.data() as LicenseDeviceRecord,
        }))
        .filter((entry) => entry.data.active === true);
    }

    const now = FieldValue.serverTimestamp();
    tx.set(
      purchaseRef,
      {
        active: params.authoritativeActive,
        environment:
          params.authoritativeEnvironment ?? purchase.environment ?? null,
        lastStoreNotificationType: params.notificationType,
        lastStoreNotificationUuid: params.notificationUuid ?? null,
        revocationDate: params.authoritativeActive
          ? null
          : params.revocationDate ?? null,
        revocationReason: params.authoritativeActive
          ? null
          : params.revocationReason ?? null,
        revocationType: params.authoritativeActive
          ? null
          : params.revocationType ?? null,
        revocationPercentage: params.authoritativeActive
          ? null
          : params.revocationPercentage ?? null,
        revokedAt: params.authoritativeActive
          ? null
          : purchase.revokedAt ?? now,
        restoredAt: params.authoritativeActive ? now : purchase.restoredAt ?? null,
        lastReconciledAt: now,
        updatedAt: now,
      },
      {merge: true}
    );

    let licenseAction: NativeStoreReconciliationResult["licenseAction"] =
      license ? "unchanged" : "missing_license";

    if (license) {
      if (shouldRevoke) {
        for (const device of activeDeviceDocs) {
          tx.update(device.ref, {
            active: false,
            deactivatedAt: now,
            lastSeenAt: now,
          });
        }
        tx.update(licenseRef, {
          status: "revoked",
          activePrimaryDevices: 0,
          activeBonusDevices: 0,
          nativeStoreRevokedPurchaseEvidenceHash: purchaseId,
          nativeStoreRevocationReason:
            params.revocationType ?? params.notificationType,
          nativeStoreRevokedAt: now,
          updatedAt: now,
        });
        licenseAction = "revoked";
      } else if (
        params.authoritativeActive &&
        shouldReactivateNativeLicense({
          source: license.source,
          status: license.status,
          revokedEvidenceHash:
            license.nativeStoreRevokedPurchaseEvidenceHash ?? null,
          currentEvidenceHash: purchaseId,
        })
      ) {
        tx.update(licenseRef, {
          status: "active",
          nativeStoreRevokedPurchaseEvidenceHash: null,
          nativeStoreRevocationReason: null,
          nativeStoreRevokedAt: null,
          updatedAt: now,
        });
        licenseAction = "reactivated";
      } else if (
        !params.authoritativeActive &&
        !shouldRevokeNativeLicense({
          source: license.source,
          remainingActiveNativePurchases,
        })
      ) {
        licenseAction = "preserved_non_native_license";
      }
    }

    const auditRef = db.collection(COL.licenseAudit).doc();
    tx.set(auditRef, {
      action: "native_store_purchase_reconciled",
      store: params.store,
      purchaseEvidenceHash: purchaseId,
      ownerUid,
      icadUid: purchase.icadUid ?? null,
      licenseId,
      authoritativeActive: params.authoritativeActive,
      notificationType: params.notificationType,
      notificationUuid: params.notificationUuid ?? null,
      authoritativeEnvironment: params.authoritativeEnvironment ?? null,
      revocationDate: params.revocationDate ?? null,
      revocationReason: params.revocationReason ?? null,
      revocationType: params.revocationType ?? null,
      revocationPercentage: params.revocationPercentage ?? null,
      licenseAction,
      deactivatedDevices: activeDeviceDocs.length,
      createdAt: now,
    });

    return {
      found: true,
      purchaseActive: params.authoritativeActive,
      licenseAction,
      ownerUid,
      licenseId,
      deactivatedDevices: activeDeviceDocs.length,
    };
  });
}
