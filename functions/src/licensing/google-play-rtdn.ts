import {logger} from "firebase-functions";
import {HttpsError} from "firebase-functions/v2/https";
import {onMessagePublished} from "firebase-functions/v2/pubsub";
import {
  COL,
  FieldValue,
  GOOGLE_PLAY_SERVICE_ACCOUNT_JSON,
  db,
} from "../core";
import {getGooglePlayAuthoritativePurchase} from "./google-play-api";
import {classifyGooglePlayRtdn} from "./google-play-notification-policy";
import {
  getNativeStorePurchaseEvidence,
  nativeStorePurchaseEvidenceId,
  reconcileNativeStorePurchase,
} from "./native-store-reconciliation";

export const FOURICAD_GOOGLE_PLAY_RTDN_TOPIC = "fouricad-google-play-rtdn";

/**
 * Google Play Real-time Developer Notifications consumer for 4iCAD.
 *
 * Security model:
 *  1. Pub/Sub accepts the Play-published lifecycle signal.
 *  2. The raw purchase token is used only in memory and is never persisted.
 *  3. The token must match existing replay-resistant 4iCAD purchase evidence.
 *  4. Google Play Developer API is re-queried before any entitlement change.
 *  5. The shared native-store reconciler can only auto-revoke licenses that
 *     were themselves created from native store purchases.
 *
 * A notification by itself can therefore never create a license or revoke an
 * unrelated Stripe/admin entitlement.
 */
export const fourICadGooglePlayNotifications = onMessagePublished(
  {
    topic: FOURICAD_GOOGLE_PLAY_RTDN_TOPIC,
    region: "us-central1",
    secrets: [GOOGLE_PLAY_SERVICE_ACCOUNT_JSON],
    retry: true,
  },
  async (event) => {
    let payload: unknown;
    try {
      payload = event.data.message.json;
    } catch (error: unknown) {
      logger.warn("Google Play RTDN payload was not valid JSON", {
        eventId: event.id,
        error: error instanceof Error ? error.message : String(error),
      });
      return;
    }

    const decision = classifyGooglePlayRtdn(payload);
    if (decision.kind === "test") {
      logger.info("Google Play RTDN test notification received", {
        eventId: event.id,
        packageName: decision.packageName,
      });
      return;
    }
    if (decision.kind === "ignore") {
      logger.info("Google Play RTDN ignored", {
        eventId: event.id,
        packageName: decision.packageName || null,
        reason: decision.reason,
      });
      return;
    }
    if (decision.kind === "invalid") {
      logger.warn("Google Play RTDN rejected as malformed", {
        eventId: event.id,
        packageName: decision.packageName || null,
        reason: decision.reason,
      });
      return;
    }

    // The purchase token never leaves memory. Lookup derives the same SHA-256
    // evidence id used when the signed-in client originally verified purchase.
    const evidence = await getNativeStorePurchaseEvidence(
      "google_play",
      decision.purchaseToken
    );
    if (!evidence) {
      // RTDN may arrive before the signed-in client finishes verification. It
      // must not create an entitlement. A later client verification re-queries
      // Google Play and creates evidence only after binding it to a 4iCAD user.
      logger.info("Google Play RTDN has no local 4iCAD purchase evidence", {
        eventId: event.id,
        notificationType: decision.notificationType,
      });
      return;
    }

    const receiptRef = db
      .collection(COL.googlePlayNotifications)
      .doc(event.id);
    const shouldProcess = await db.runTransaction(async (tx) => {
      const snap = await tx.get(receiptRef);
      if (snap.exists && snap.data()?.status === "processed") return false;
      tx.set(
        receiptRef,
        {
          eventId: event.id,
          notificationType: decision.notificationType,
          packageName: decision.packageName,
          eventTimeMillis: decision.eventTimeMillis,
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
      return;
    }

    try {
      const authoritative = await getGooglePlayAuthoritativePurchase(
        decision.purchaseToken
      );
      const authoritativeEvidenceId = nativeStorePurchaseEvidenceId(
        "google_play",
        decision.purchaseToken
      );
      if (authoritativeEvidenceId !== evidence.id) {
        throw new HttpsError(
          "permission-denied",
          "Google Play authoritative purchase did not match stored evidence."
        );
      }

      // Full refunds/cancellations must be visible in ProductPurchaseV2 before
      // access is removed. Throwing makes Pub/Sub retry instead of acknowledging
      // an event that arrived before the Developer API became consistent.
      if (decision.expectsInactive && authoritative.active) {
        throw new HttpsError(
          "unavailable",
          "Google Play purchase state has not reflected the revocation yet."
        );
      }

      const result = await reconcileNativeStorePurchase({
        store: "google_play",
        externalPurchaseId: decision.purchaseToken,
        authoritativeActive: authoritative.active,
        notificationType: decision.notificationType,
        notificationUuid: event.id,
        authoritativeEnvironment: authoritative.environment,
        revocationDate: authoritative.active
          ? null
          : Number(decision.eventTimeMillis ?? "") || null,
        revocationReason: authoritative.active
          ? null
          : decision.revocationReason,
        revocationType: authoritative.active
          ? null
          : decision.revocationType,
        revocationPercentage: null,
      });

      await receiptRef.set(
        {
          status: "processed",
          authoritativeActive: authoritative.active,
          purchaseState: authoritative.purchaseState,
          refundableQuantity: authoritative.refundableQuantity,
          orderId: authoritative.orderId,
          environment: authoritative.environment,
          licenseAction: result.licenseAction,
          ownerUid: result.ownerUid,
          licenseId: result.licenseId,
          deactivatedDevices: result.deactivatedDevices,
          processedAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true}
      );

      logger.info("Google Play entitlement notification reconciled", {
        eventId: event.id,
        notificationType: decision.notificationType,
        authoritativeActive: authoritative.active,
        purchaseState: authoritative.purchaseState,
        environment: authoritative.environment,
        licenseAction: result.licenseAction,
        deactivatedDevices: result.deactivatedDevices,
      });
    } catch (error: unknown) {
      const message =
        error instanceof Error
          ? error.message
          : "Google Play notification reconciliation failed.";
      await receiptRef.set(
        {
          status: "error",
          error: message,
          erroredAt: FieldValue.serverTimestamp(),
          updatedAt: FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      logger.error("Google Play notification reconciliation failed", {
        eventId: event.id,
        notificationType: decision.notificationType,
        message,
      });
      throw error;
    }
  }
);
