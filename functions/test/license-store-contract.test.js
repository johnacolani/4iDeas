const test = require("node:test");
const assert = require("node:assert/strict");

const {
  LICENSE_PLAN_POLICIES,
  decideNewActivation,
  isDevicePlatform,
} = require("../lib/licensing/license-policy.js");

test("individual and company limits stay fixed", () => {
  assert.equal(LICENSE_PLAN_POLICIES.individual.primaryDeviceLimit, 1);
  assert.equal(LICENSE_PLAN_POLICIES.individual.bonusOtherPlatformLimit, 1);
  assert.equal(LICENSE_PLAN_POLICIES.company.primaryDeviceLimit, 10);
  assert.equal(LICENSE_PLAN_POLICIES.company.bonusOtherPlatformLimit, 3);
});

test("same platform consumes primary and another platform consumes bonus", () => {
  assert.equal(
    decideNewActivation("individual", "windows", "windows", {
      primaryActive: 0,
      bonusActive: 0,
    }).bucket,
    "primary"
  );
  assert.equal(
    decideNewActivation("individual", "windows", "macos", {
      primaryActive: 0,
      bonusActive: 0,
    }).bucket,
    "bonus"
  );
});

test("native platform validation excludes web during phase one", () => {
  assert.equal(isDevicePlatform("windows"), true);
  assert.equal(isDevicePlatform("ios"), true);
  assert.equal(isDevicePlatform("web"), false);
  assert.equal(isDevicePlatform(""), false);
});
