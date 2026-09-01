const test = require("node:test");
const assert = require("node:assert/strict");

const {
  INDIVIDUAL_POLICY,
  COMPANY_POLICY,
  classifyActivationSlot,
} = require("../lib/licensing/license-policy.js");

test("individual and company limits stay fixed", () => {
  assert.equal(INDIVIDUAL_POLICY.baseDeviceLimit, 1);
  assert.equal(INDIVIDUAL_POLICY.bonusOtherPlatformLimit, 1);
  assert.equal(COMPANY_POLICY.baseDeviceLimit, 10);
  assert.equal(COMPANY_POLICY.bonusOtherPlatformLimit, 3);
});

test("same platform consumes base and another platform consumes bonus", () => {
  assert.equal(classifyActivationSlot("windows", "windows"), "base");
  assert.equal(classifyActivationSlot("windows", "macos"), "bonus");
  assert.equal(classifyActivationSlot("macos", "ios"), "bonus");
});
