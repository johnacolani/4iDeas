const test = require("node:test");
const assert = require("node:assert/strict");
const {
  normalizeGiftEmail,
  giftIdForEmail,
  giftOwnerUid,
  decideGiftClaim,
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

test("verified-email gift can be claimed once then reused by same iCAD UID", () => {
  const gift = {email: "customer@example.com", status: "pending"};
  assert.equal(
    decideGiftClaim(gift, " Customer@Example.com ", "uid-1", false), "new"
  );
  const claimed = {
    email: "customer@example.com", status: "claimed", claimedByIcadUid: "uid-1",
  };
  assert.equal(decideGiftClaim(claimed, gift.email, "uid-1", true), "existing");
  assert.equal(decideGiftClaim(claimed, gift.email, "uid-2", true), "none");
  assert.equal(decideGiftClaim(claimed, gift.email, "uid-1", false), "none");
});

test("gift will not be claimed for a different email or after cancellation", () => {
  const gift = {email: "customer@example.com", status: "pending"};
  assert.equal(decideGiftClaim(gift, "other@example.com", "uid", false), "none");
  assert.equal(decideGiftClaim(undefined, gift.email, "uid", false), "none");
  assert.equal(
    decideGiftClaim({...gift, status: "cancelled"}, gift.email, "uid", false),
    "none"
  );
});
