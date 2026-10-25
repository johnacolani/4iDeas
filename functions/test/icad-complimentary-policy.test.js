const test = require("node:test");
const assert = require("node:assert/strict");
const {
  normalizeGiftEmail,
  giftIdForEmail,
  giftOwnerUid,
} = require("../lib/licensing/icad-complimentary-policy.js");

test("gift lookup is case insensitive and cannot use raw email as document id", () => {
  assert.equal(normalizeGiftEmail("  Example.User@Gmail.COM  "), "example.user@gmail.com");
  const id = giftIdForEmail("Example.User@Gmail.COM");
  assert.equal(id, giftIdForEmail(" example.user@gmail.com "));
  assert.match(id, /^[0-9a-f]{64}$/);
  assert.ok(!id.includes("@"));
});

test("gift owners never collide with website or native-store accounts", () => {
  assert.equal(giftOwnerUid("actual-icad-uid"), "icad-gift:actual-icad-uid");
  assert.notEqual(giftOwnerUid("abc"), "abc");
  assert.notEqual(giftOwnerUid("abc"), "icad-store:abc");
  assert.throws(() => giftOwnerUid("../bad"), /Invalid/);
});

test("invalid email is rejected before grant reservation", () => {
  for (const value of ["", "invalid", "x@y", "x y@example.com"]) {
    assert.throws(() => normalizeGiftEmail(value));
  }
});
