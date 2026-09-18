const test = require("node:test");
const assert = require("node:assert/strict");

const {
  isTestStoreLicenseSource,
} = require("../lib/licensing/native-store-source-policy.js");

test("sandbox store license sources do not receive production precedence", () => {
  assert.equal(isTestStoreLicenseSource("app_store_test"), true);
  assert.equal(isTestStoreLicenseSource("google_play_test"), true);
});

test("production and complimentary license sources keep normal precedence", () => {
  assert.equal(isTestStoreLicenseSource("app_store"), false);
  assert.equal(isTestStoreLicenseSource("google_play"), false);
  assert.equal(isTestStoreLicenseSource("admin_complimentary"), false);
  assert.equal(isTestStoreLicenseSource("stripe_checkout"), false);
  assert.equal(isTestStoreLicenseSource(null), false);
});
