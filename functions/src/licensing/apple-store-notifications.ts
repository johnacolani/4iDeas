import {createHash} from "node:crypto";
import {logger} from "firebase-functions";
import {HttpsError, onRequest} from "firebase-functions/v2/https";
import {
  APPLE_IAP_ISSUER_ID,
  APPLE_IAP_KEY_ID,
  APPLE_IAP_PRIVATE_KEY,
  APPLE_IAP_SANDBOX_ENABLED,
  COL,
  FieldValue,
  db,
} from "../core";
import {verifyAndDecodeAppleJws, type AppleJwsObject} from "./apple-jws";
import {
  APPLE_BUNDLE_IDENTIFIER,
  APPLE_FULL_ACCESS_PRODUCT_ID,
  appleSandboxEnabled,
  getAppleAuthoritativeTransaction,
} from "./apple-store-api";
import {
  authoritativeActiveForAppleNotification,
  isAppleEntitlementNotification,
} from "./apple-notification-policy";
import {
  getNativeStorePurchaseEvidence,
  nativeStorePurchaseEvidenceId,
  reconcileNativeStorePurchase,
} from "./native-store-reconciliation";

function objectOrNull(value: unknown): AppleJwsObject | null {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? (value as AppleJwsObject)
    : null;
}

function notificationReceiptId(
  notificationUuid: string,
  signedPayload: string
): string {
  if (notificationUuid) return notificationUuid;
  return createHash("sha256").update(signedPayload, "utf8").digest("hex");
}

function statusForError(error: unknown): number {
  if (!(error instanceof HttpsError)) return 500;
  switch (error.code) {
    case "invalid-argument":
      return 400;
    case "permission-denied":
      return 403;
    case "not-found":
      return 404;
    case "failed-precondition":
      return 409;
    case "unavailable":
      return 503;
    default:
      return 500;
  }
}

/**
 * App Store Server Notifications V2 endpoint for 4iCAD.
 *
 * Security model:
 *  1. Verify Apple's ES256 JWS signature and Apple App Store certificate chain.
 *  2. Verify the nested signed transaction and app/product/environment identity.
 *  3. Require an already-known replay-resistant native purchase record.
 *  4. Re-query the authenticated App Store Server API before changing access.
 *
 * A notification by itself can therefore never create an entitlement or revoke
 * an unrelated license.
 */
export const fourICadAppleStoreNotifications = onRequest(
  {
    region: "us-central1",
    secrets: [
      APPLE_IAP_KEY_ID,
      APPLE_IAP_ISSUER_ID,
      APPLE_IAP_PRIVATE_KEY,
      APPLE_IAP_SANDBOX_ENABLED,
    ],
    cors: false,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const signedPayload = String(req.body?.signedPayload ?? "").trim();
    if (!signedPayload) {
      res.status(400).send("Missing signedPayload");
      return;
    }

    let notification: AppleJwsObject;
    try {
      notification = verifyAndDecodeAppleJws(signedPayload);
    } catch (error: unknown) {
      logger.warn("Apple notification JWS verification failed", {
        error: error instanceof Error ? error.message : String(error),
      });
      res.status(400).send("Invalid signedPayload");
      return;
    }

    const notificationType = String(notification.notificationType ?? "").trim();
    const notificationUuid = String(notification.notificationUUID ?? "").trim();
    const data = objectOrNull(notification.data);

    if (notificationType === "TEST") {
      const testBundleId = String(data?.bundleId ?? "").trim();
      if (testBundleId && testBundleId !== APPLE_BUNDLE_IDENTIFIER) {
        res.status(400).send("Wrong bundle");
        return;
      }
      logger.info("Apple App Store test notification verified", {
        notificationUuid: notificationUuid || null,
        environment: data?.environment ?? null,
      });
      res.status(200).send("ok");
      return;
    }

    if (!isAppleEntitlementNotification(notificationType)) {
      // ONE_TIME_CHARGE and other lifecycle notifications never grant access
      // here. Purchase creation stays behind the signed-in client verification
      // endpoint, which binds the store transaction to a 4iCAD account.
      res.status(200).send("ignored");
      return;
    }

    if (!data) {
      res.status(400).send("Missing notification data");
      return;
    }

    const bundleId = String(data.bundleId ?? "").trim();
    const environment = String(data.environment ?? "").trim().toLowerCase();
    if (bundleId !== APPLE_BUNDLE_IDENTIFIER) {
      res.status(400).send("Wrong bundle");
      return;
    }
    if (environment !== "production" && environment !== "sandbox") {
      res.status(400).send("Invalid environment");
      return;
    }
    if (environment === "sandbox" && !appleSandboxEnabled()) {
      res.status(403).send("Sandbox disabled");
      return;
    }

    const signedTransactionInfo = String(data.signedTransactionInfo ?? "").trim();
    if (!signedTransactionInfo) {
      res.status(400).send("Missing signed transaction");
      return;
    }

    let signedTransaction: AppleJwsObject;
    try {
      signedTransaction = verifyAndDecodeAppleJws(signedTransactionInfo);
    } catch (error: unknown) {
      logger.warn("Apple notification transaction JWS verification failed", {
        notificationUuid: notificationUuid || null,
        error: error instanceof Error ? error.message : String(error),
      });
      res.status(400).send("Invalid signed transaction");
      return;
    }

    const transactionBundleId = String(signedTransaction.bundleId ?? "").trim();
    const productId = String(signedTransaction.productId ?? "").trim();
    const transactionEnvironment = String(
      signedTransaction.environment ?? environment
    )
      .trim()
      .toLowerCase();
    const transactionId = String(signedTransaction.transactionId ?? "").trim();
    const originalTransactionId = String(
      signedTransaction.originalTransactionId ?? transactionId
    ).trim();

    if (
      transactionBundleId !== APPLE_BUNDLE_IDENTIFIER ||
      productId !== APPLE_FULL_ACCESS_PRODUCT_ID ||
      transactionEnvironment !== environment ||
      !transactionId ||
      !originalTransactionId
    ) {
      res.status(400).send("Transaction does not match 4iCAD Full Access");
      return;
    }

    let evidence = await getNativeStorePurchaseEvidence(
      "apple",
      originalTransactionId
    );
    if (!evidence && transactionId !== originalTransactionId) {
      evidence = await getNativeStorePurchaseEvidence("apple", transactionId);
    }
    if (!evidence) {
      // No entitlement was ever granted from this transaction, so there is
      // nothing for this endpoint to revoke. A later grant attempt still has to
      // re-query Apple and will reject a revoked purchase.
      logger.info("Apple notification has no local 4iCAD purchase evidence", {
        notificationType,
        notificationUuid: notificationUuid || null,
      });
      res.status(200).send("ignored");
      return;
    }

    const receiptId = notificationReceiptId(notificationUuid, signedPayload);
    const receiptRef = db.collection(COL.appleStoreNotifications).doc(receiptId);
    const shouldProcess = await db.runTransaction(async (tx) => {
      const snap = await tx.get(receiptRef);
      if (snap.exists && snap.data()?.status === "processed") return false;
      tx.set(
        receiptRef,
        {
          notificationUuid: notificationUuid || null,
          notificationType,
          environment,
          purchaseEvidenceHash: evidence.id,
          status: "processing",
          receivedAt: snap.data()?.receivedAt ?? FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      return true;
    });

    if (!shouldProcess) {
      res.status(200).send("Already processed");
      return;
    }

    try {
      const authoritative = await getAppleAuthoritativeTransaction(transactionId);
      const authoritativeEvidenceId = nativeStorePurchaseEvidenceId(
        "apple",
        authoritative.originalTransactionId
      );
      if (authoritativeEvidenceId !== evidence.id) {
        throw new HttpsError(
          "permission-denied",
          "Apple authoritative transaction did not match stored purchase evidence."
        );
      }
      if (authoritative.environment !== environment) {
        throw new HttpsError(
          "permission-denied",
          "Apple authoritative environment did not match the notification."
        );
      }

      // For revocation/refund we require the server API to already reflect the
      // revocation. Returning a retryable error avoids acknowledging an event
      // that arrived before Apple's transaction endpoint became consistent.
      if (
        notificationType !== "REFUND_REVERSED" &&
        authoritative.revoked !== true
      ) {
        throw new HttpsError(
          "unavailable",
          "Apple transaction state has not reflected the revocation yet."
        );
      }

      const authoritativeActive = authoritativeActiveForAppleNotification({
        notificationType,
        transactionRevoked: authoritative.revoked,
      });
      const result = await reconcileNativeStorePurchase({
        store: "apple",
        externalPurchaseId: authoritative.originalTransactionId,
        authoritativeActive,
        notificationType,
        notificationUuid: notificationUuid || null,
        authoritativeEnvironment: authoritative.environment,
        revocationDate: authoritative.revocationDate,
        revocationReason: authoritative.revocationReason,
        revocationType: authoritative.revocationType,
        revocationPercentage: authoritative.revocationPercentage,
      });

      await receiptRef.set(
        {
          status: "processed",
          authoritativeActive,
          licenseAction: result.licenseAction,
          ownerUid: result.ownerUid,
          licenseId: result.licenseId,
          deactivatedDevices: result.deactivatedDevices,
          processedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true}
      );

      logger.info("Apple entitlement notification reconciled", {
        notificationType,
        notificationUuid: notificationUuid || null,
        environment,
        authoritativeActive,
        licenseAction: result.licenseAction,
        deactivatedDevices: result.deactivatedDevices,
      });
      res.status(200).send("ok");
    } catch (error: unknown) {
      const status = statusForError(error);
      const message =
        error instanceof HttpsError
          ? error.message
          : error instanceof Error
            ? error.message
            : "Apple notification reconciliation failed.";
      await receiptRef.set(
        {
          status: "error",
          error: message,
          erroredAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      logger.error("Apple notification reconciliation failed", {
        notificationType,
        notificationUuid: notificationUuid || null,
        status,
        message,
      });
      res.status(status).send("Handler error");
    }
  }
);
