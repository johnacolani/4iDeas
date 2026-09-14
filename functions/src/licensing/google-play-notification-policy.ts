export const GOOGLE_PLAY_PACKAGE_NAME = "com.johncolani.fouricad";
export const GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID =
  "com.johncolani.fouricad.fullaccess";

export type GooglePlayRtdnDecision =
  | {kind: "test"; packageName: string}
  | {kind: "ignore"; packageName: string; reason: string}
  | {kind: "invalid"; packageName: string; reason: string}
  | {
      kind: "reconcile";
      packageName: string;
      purchaseToken: string;
      notificationType: string;
      expectsInactive: boolean;
      eventTimeMillis: string | null;
      orderId: string | null;
      revocationType: string | null;
      revocationReason: string | null;
    };

type JsonObject = Record<string, unknown>;

function objectOrNull(value: unknown): JsonObject | null {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? (value as JsonObject)
    : null;
}

function stringValue(value: unknown): string {
  return String(value ?? "").trim();
}

function intValue(value: unknown): number | null {
  const parsed = Number(value);
  return Number.isInteger(parsed) ? parsed : null;
}

/**
 * Classify a Google Play Real-time Developer Notification without trusting it
 * to make an entitlement decision. The caller must still re-query the Google
 * Play Developer API before changing any stored purchase or license state.
 */
export function classifyGooglePlayRtdn(payload: unknown): GooglePlayRtdnDecision {
  const root = objectOrNull(payload);
  if (!root) {
    return {kind: "invalid", packageName: "", reason: "payload_not_object"};
  }

  const packageName = stringValue(root.packageName);
  if (packageName !== GOOGLE_PLAY_PACKAGE_NAME) {
    return {kind: "ignore", packageName, reason: "wrong_package"};
  }

  if (objectOrNull(root.testNotification)) {
    return {kind: "test", packageName};
  }

  const eventTimeMillis = stringValue(root.eventTimeMillis) || null;
  const oneTime = objectOrNull(root.oneTimeProductNotification);
  if (oneTime) {
    const purchaseToken = stringValue(oneTime.purchaseToken);
    if (!purchaseToken) {
      return {kind: "invalid", packageName, reason: "missing_purchase_token"};
    }

    const sku = stringValue(oneTime.sku);
    if (sku && sku !== GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID) {
      return {kind: "ignore", packageName, reason: "wrong_product"};
    }

    const type = intValue(oneTime.notificationType);
    if (type === 1) {
      return {
        kind: "reconcile",
        packageName,
        purchaseToken,
        notificationType: "ONE_TIME_PRODUCT_PURCHASED",
        expectsInactive: false,
        eventTimeMillis,
        orderId: null,
        revocationType: null,
        revocationReason: null,
      };
    }
    if (type === 2) {
      return {
        kind: "reconcile",
        packageName,
        purchaseToken,
        notificationType: "ONE_TIME_PRODUCT_CANCELED",
        expectsInactive: true,
        eventTimeMillis,
        orderId: null,
        revocationType: "canceled",
        revocationReason: "google_play_one_time_product_canceled",
      };
    }
    return {
      kind: "ignore",
      packageName,
      reason: "unsupported_one_time_notification",
    };
  }

  const voided = objectOrNull(root.voidedPurchaseNotification);
  if (voided) {
    const purchaseToken = stringValue(voided.purchaseToken);
    if (!purchaseToken) {
      return {kind: "invalid", packageName, reason: "missing_purchase_token"};
    }

    // RTDN productType 2 means a one-time product. Subscription voids are not
    // part of 4iCAD's one-time Full Access product model.
    if (intValue(voided.productType) !== 2) {
      return {kind: "ignore", packageName, reason: "non_one_time_void"};
    }

    const refundType = intValue(voided.refundType);
    const fullRefund = refundType === 1;
    return {
      kind: "reconcile",
      packageName,
      purchaseToken,
      notificationType: fullRefund
        ? "VOIDED_PURCHASE_FULL_REFUND"
        : refundType === 2
          ? "VOIDED_PURCHASE_PARTIAL_REFUND"
          : "VOIDED_PURCHASE",
      // A full refund must be reflected by the authoritative API before we
      // remove access. Partial quantity refunds may legitimately leave a
      // purchase active, so those simply follow the authoritative state.
      expectsInactive: fullRefund,
      eventTimeMillis,
      orderId: stringValue(voided.orderId) || null,
      revocationType: fullRefund ? "full_refund" : "partial_refund",
      revocationReason: "google_play_voided_purchase",
    };
  }

  return {kind: "ignore", packageName, reason: "unrelated_notification"};
}

/**
 * ProductPurchaseV2 is authoritative. A purchase is active only when Google
 * reports PURCHASED and the Full Access line item has not been fully refunded.
 */
export function authoritativeGooglePurchaseActive(params: {
  purchaseState: string;
  refundableQuantity: number | null;
}): boolean {
  if (params.purchaseState !== "PURCHASED") return false;
  return params.refundableQuantity === null || params.refundableQuantity > 0;
}
