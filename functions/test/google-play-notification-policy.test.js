const test = require("node:test");
const assert = require("node:assert/strict");

const {
  GOOGLE_PLAY_PACKAGE_NAME,
  GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID,
  classifyGooglePlayRtdn,
  authoritativeGooglePurchaseActive,
} = require("../lib/licensing/google-play-notification-policy.js");

test("Google Play RTDN accepts test notifications for 4iCAD", () => {
  assert.deepEqual(
    classifyGooglePlayRtdn({
      version: "1.0",
      packageName: GOOGLE_PLAY_PACKAGE_NAME,
      testNotification: {version: "1.0"},
    }),
    {kind: "test", packageName: GOOGLE_PLAY_PACKAGE_NAME}
  );
});

test("Google Play RTDN classifies completed one-time purchases", () => {
  const result = classifyGooglePlayRtdn({
    version: "1.0",
    packageName: GOOGLE_PLAY_PACKAGE_NAME,
    eventTimeMillis: "1789400000000",
    oneTimeProductNotification: {
      version: "1.0",
      notificationType: 1,
      purchaseToken: "token-a",
      sku: GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID,
    },
  });
  assert.equal(result.kind, "reconcile");
  assert.equal(result.notificationType, "ONE_TIME_PRODUCT_PURCHASED");
  assert.equal(result.expectsInactive, false);
  assert.equal(result.purchaseToken, "token-a");
});

test("Google Play RTDN requires authoritative cancellation before removal", () => {
  const result = classifyGooglePlayRtdn({
    packageName: GOOGLE_PLAY_PACKAGE_NAME,
    oneTimeProductNotification: {
      notificationType: 2,
      purchaseToken: "token-b",
      sku: GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID,
    },
  });
  assert.equal(result.kind, "reconcile");
  assert.equal(result.notificationType, "ONE_TIME_PRODUCT_CANCELED");
  assert.equal(result.expectsInactive, true);
});

test("Google Play RTDN handles one-time full refunds without trusting the event alone", () => {
  const result = classifyGooglePlayRtdn({
    packageName: GOOGLE_PLAY_PACKAGE_NAME,
    eventTimeMillis: "1789400000000",
    voidedPurchaseNotification: {
      purchaseToken: "token-c",
      orderId: "GPA.1234-5678-9012-34567",
      productType: 2,
      refundType: 1,
    },
  });
  assert.equal(result.kind, "reconcile");
  assert.equal(result.notificationType, "VOIDED_PURCHASE_FULL_REFUND");
  assert.equal(result.expectsInactive, true);
  assert.equal(result.revocationType, "full_refund");
});

test("Google Play RTDN ignores unrelated packages, products, and subscriptions", () => {
  assert.equal(
    classifyGooglePlayRtdn({
      packageName: "com.example.other",
      testNotification: {version: "1.0"},
    }).kind,
    "ignore"
  );
  assert.equal(
    classifyGooglePlayRtdn({
      packageName: GOOGLE_PLAY_PACKAGE_NAME,
      oneTimeProductNotification: {
        notificationType: 1,
        purchaseToken: "token-d",
        sku: "com.example.other.product",
      },
    }).kind,
    "ignore"
  );
  assert.equal(
    classifyGooglePlayRtdn({
      packageName: GOOGLE_PLAY_PACKAGE_NAME,
      voidedPurchaseNotification: {
        purchaseToken: "token-e",
        productType: 1,
        refundType: 1,
      },
    }).kind,
    "ignore"
  );
});

test("Google Play authoritative purchase state controls entitlement", () => {
  assert.equal(
    authoritativeGooglePurchaseActive({
      purchaseState: "PURCHASED",
      refundableQuantity: 1,
    }),
    true
  );
  assert.equal(
    authoritativeGooglePurchaseActive({
      purchaseState: "PURCHASED",
      refundableQuantity: null,
    }),
    true
  );
  assert.equal(
    authoritativeGooglePurchaseActive({
      purchaseState: "PURCHASED",
      refundableQuantity: 0,
    }),
    false
  );
  assert.equal(
    authoritativeGooglePurchaseActive({
      purchaseState: "CANCELLED",
      refundableQuantity: 1,
    }),
    false
  );
  assert.equal(
    authoritativeGooglePurchaseActive({
      purchaseState: "PENDING",
      refundableQuantity: 1,
    }),
    false
  );
});

test("Google Play RTDN rejects a reconcile event with no purchase token", () => {
  const result = classifyGooglePlayRtdn({
    packageName: GOOGLE_PLAY_PACKAGE_NAME,
    oneTimeProductNotification: {
      notificationType: 1,
      sku: GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID,
    },
  });
  assert.equal(result.kind, "invalid");
  assert.equal(result.reason, "missing_purchase_token");
});
