const test = require("node:test");
const assert = require("node:assert/strict");

const {
  LICENSE_PLAN_POLICIES,
  decideNewActivation,
  isWebCheckoutPrimaryPlatform,
} = require("../lib/licensing/license-policy.js");

test("individual license is 1 primary + 1 bonus", () => {
  assert.deepEqual(LICENSE_PLAN_POLICIES.individual, {
    plan: "individual",
    primaryDeviceLimit: 1,
    bonusOtherPlatformLimit: 1,
    totalDeviceLimit: 2,
  });
});

test("company license is 10 primary + 3 bonus", () => {
  assert.deepEqual(LICENSE_PLAN_POLICIES.company, {
    plan: "company",
    primaryDeviceLimit: 10,
    bonusOtherPlatformLimit: 3,
    totalDeviceLimit: 13,
  });
});

test("website checkout primary platforms exclude app-store platforms", () => {
  assert.equal(isWebCheckoutPrimaryPlatform("windows"), true);
  assert.equal(isWebCheckoutPrimaryPlatform("macos"), true);
  assert.equal(isWebCheckoutPrimaryPlatform("linux"), true);
  assert.equal(isWebCheckoutPrimaryPlatform("ios"), false);
  assert.equal(isWebCheckoutPrimaryPlatform("android"), false);
  assert.equal(isWebCheckoutPrimaryPlatform("web"), false);
});

test("individual primary seat blocks the second primary device", () => {
  assert.deepEqual(
    decideNewActivation("individual", "windows", "windows", {
      primaryActive: 1,
      bonusActive: 0,
    }),
    {
      allowed: false,
      bucket: "primary",
      reason: "primary_limit_reached",
    }
  );
});

test("individual bonus seat accepts one different platform then blocks another", () => {
  assert.deepEqual(
    decideNewActivation("individual", "windows", "macos", {
      primaryActive: 1,
      bonusActive: 0,
    }),
    {allowed: true, bucket: "bonus", reason: "available"}
  );

  assert.deepEqual(
    decideNewActivation("individual", "windows", "android", {
      primaryActive: 1,
      bonusActive: 1,
    }),
    {
      allowed: false,
      bucket: "bonus",
      reason: "bonus_limit_reached",
    }
  );
});

test("company allows the tenth primary and third bonus activations only", () => {
  assert.equal(
    decideNewActivation("company", "windows", "windows", {
      primaryActive: 9,
      bonusActive: 3,
    }).allowed,
    true
  );

  assert.equal(
    decideNewActivation("company", "windows", "windows", {
      primaryActive: 10,
      bonusActive: 2,
    }).allowed,
    false
  );

  assert.equal(
    decideNewActivation("company", "windows", "ios", {
      primaryActive: 10,
      bonusActive: 2,
    }).allowed,
    true
  );

  assert.equal(
    decideNewActivation("company", "windows", "ios", {
      primaryActive: 10,
      bonusActive: 3,
    }).allowed,
    false
  );
});
