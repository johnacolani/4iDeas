const test = require("node:test");
const assert = require("node:assert/strict");

const {
  isNativeOnlyLicenseSource,
  shouldRevokeNativeLicense,
  shouldReactivateNativeLicense,
} = require("../lib/licensing/native-store-reconciliation-policy.js");
const {
  isAppleEntitlementNotification,
  authoritativeActiveForAppleNotification,
} = require("../lib/licensing/apple-notification-policy.js");

test("only native-created licenses are auto-revoked by store refunds", () => {
  assert.equal(isNativeOnlyLicenseSource("app_store"), true);
  assert.equal(isNativeOnlyLicenseSource("app_store_test"), true);
  assert.equal(isNativeOnlyLicenseSource("google_play"), true);
  assert.equal(isNativeOnlyLicenseSource("stripe_checkout"), false);
  assert.equal(isNativeOnlyLicenseSource("complimentary"), false);

  assert.equal(
    shouldRevokeNativeLicense({
      source: "app_store",
      remainingActiveNativePurchases: 0,
    }),
    true
  );
  assert.equal(
    shouldRevokeNativeLicense({
      source: "app_store",
      remainingActiveNativePurchases: 1,
    }),
    false
  );
  assert.equal(
    shouldRevokeNativeLicense({
      source: "stripe_checkout",
      remainingActiveNativePurchases: 0,
    }),
    false
  );
});

test("refund reversal cannot undo an unrelated admin revocation", () => {
  assert.equal(
    shouldReactivateNativeLicense({
      source: "app_store_test",
      status: "revoked",
      revokedEvidenceHash: "purchase-a",
      currentEvidenceHash: "purchase-a",
    }),
    true
  );
  assert.equal(
    shouldReactivateNativeLicense({
      source: "app_store_test",
      status: "revoked",
      revokedEvidenceHash: "purchase-b",
      currentEvidenceHash: "purchase-a",
    }),
    false
  );
  assert.equal(
    shouldReactivateNativeLicense({
      source: "stripe_checkout",
      status: "revoked",
      revokedEvidenceHash: "purchase-a",
      currentEvidenceHash: "purchase-a",
    }),
    false
  );
});

test("Apple refund policy requires authoritative revocation before removal", () => {
  assert.equal(isAppleEntitlementNotification("REFUND"), true);
  assert.equal(isAppleEntitlementNotification("REVOKE"), true);
  assert.equal(isAppleEntitlementNotification("REFUND_REVERSED"), true);
  assert.equal(isAppleEntitlementNotification("ONE_TIME_CHARGE"), false);

  assert.equal(
    authoritativeActiveForAppleNotification({
      notificationType: "REFUND",
      transactionRevoked: true,
    }),
    false
  );
  assert.equal(
    authoritativeActiveForAppleNotification({
      notificationType: "REFUND",
      transactionRevoked: false,
    }),
    true
  );
  assert.equal(
    authoritativeActiveForAppleNotification({
      notificationType: "REFUND_REVERSED",
      transactionRevoked: true,
    }),
    true
  );
});
