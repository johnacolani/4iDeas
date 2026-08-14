/**
 * Unit tests for the callable authorization guards.
 *
 * These exercise the guards directly rather than through a deployed function,
 * because the guards are the security boundary: `createCheckoutSession` does
 * nothing before `requireVerifiedAuth` returns.
 *
 * Run with:  npm --prefix functions test
 */

const {test, describe} = require("node:test");
const assert = require("node:assert");
const {
  requireAuth,
  requireVerifiedAuth,
  requireAdmin,
  LEGACY_ADMIN_EMAILS,
} = require("../lib/auth-guards");

/** Builds a CallableRequest-shaped object with the given verified token. */
function callable(auth) {
  return {data: {}, auth, rawRequest: {}, acceptsStreaming: false};
}

const signedOut = callable(undefined);

const unverifiedPassword = callable({
  uid: "u-unverified",
  token: {email: "new@example.com", email_verified: false, firebase: {sign_in_provider: "password"}},
});

const verifiedPassword = callable({
  uid: "u-verified",
  token: {email: "buyer@example.com", email_verified: true, firebase: {sign_in_provider: "password"}},
});

const googleUser = callable({
  uid: "u-google",
  token: {email: "g@example.com", email_verified: true, firebase: {sign_in_provider: "google.com"}},
});

const appleUser = callable({
  uid: "u-apple",
  token: {email: "a@privaterelay.appleid.com", email_verified: true, firebase: {sign_in_provider: "apple.com"}},
});

/** A token where the claim is absent entirely rather than false. */
const missingClaim = callable({
  uid: "u-missing",
  token: {email: "x@example.com"},
});

function expectHttpsError(fn, code) {
  try {
    fn();
  } catch (err) {
    assert.strictEqual(err.code, code, `expected ${code}, got ${err.code}`);
    return err;
  }
  assert.fail(`expected the guard to throw ${code}, but it returned normally`);
}

describe("requireAuth", () => {
  test("rejects an unauthenticated caller", () => {
    expectHttpsError(() => requireAuth(signedOut), "unauthenticated");
  });

  test("rejects an auth object with no uid", () => {
    expectHttpsError(() => requireAuth(callable({token: {email: "x@y.z"}})), "unauthenticated");
  });

  test("accepts any signed-in caller and returns uid and email", () => {
    const caller = requireAuth(verifiedPassword);
    assert.strictEqual(caller.uid, "u-verified");
    assert.strictEqual(caller.email, "buyer@example.com");
  });

  test("tolerates a token with no email claim", () => {
    const caller = requireAuth(callable({uid: "u1", token: {}}));
    assert.strictEqual(caller.email, null);
  });
});

describe("requireVerifiedAuth — the purchase gate", () => {
  test("1. an unauthenticated user cannot start checkout", () => {
    expectHttpsError(() => requireVerifiedAuth(signedOut), "unauthenticated");
  });

  test("2. an unverified email/password user cannot start checkout", () => {
    const err = expectHttpsError(
      () => requireVerifiedAuth(unverifiedPassword),
      "failed-precondition"
    );
    // The UI branches on this marker, so it is part of the contract.
    assert.strictEqual(err.details.reason, "email_not_verified");
    assert.match(err.message, /verify your email/i);
  });

  test("a token missing email_verified entirely is treated as unverified", () => {
    // Absent must not be read as permission.
    expectHttpsError(() => requireVerifiedAuth(missingClaim), "failed-precondition");
  });

  test("a truthy-but-not-true claim does not pass", () => {
    const spoofed = callable({uid: "u", token: {email: "x@y.z", email_verified: "true"}});
    expectHttpsError(() => requireVerifiedAuth(spoofed), "failed-precondition");
  });

  test("3. a verified email/password user reaches checkout creation", () => {
    const caller = requireVerifiedAuth(verifiedPassword);
    assert.strictEqual(caller.uid, "u-verified");
  });

  test("Google accounts Firebase reports as verified may purchase", () => {
    assert.strictEqual(requireVerifiedAuth(googleUser).uid, "u-google");
  });

  test("Apple accounts Firebase reports as verified may purchase", () => {
    assert.strictEqual(requireVerifiedAuth(appleUser).uid, "u-apple");
  });
});

describe("requireAdmin is unchanged by the verification work", () => {
  test("rejects a signed-out caller", () => {
    expectHttpsError(() => requireAdmin(signedOut), "unauthenticated");
  });

  test("rejects an ordinary signed-in user", () => {
    expectHttpsError(() => requireAdmin(verifiedPassword), "permission-denied");
  });

  test("accepts the admin custom claim", () => {
    const req = callable({uid: "a1", token: {email: "a@b.c", admin: true}});
    assert.strictEqual(requireAdmin(req).uid, "a1");
  });

  test("accepts the legacy allowlisted email during migration", () => {
    const req = callable({uid: "a2", token: {email: LEGACY_ADMIN_EMAILS[0]}});
    assert.strictEqual(requireAdmin(req).uid, "a2");
  });

  test("matches the legacy email case-insensitively", () => {
    const req = callable({uid: "a3", token: {email: LEGACY_ADMIN_EMAILS[0].toUpperCase()}});
    assert.strictEqual(requireAdmin(req).uid, "a3");
  });

  test("does not require a verified email for admin actions", () => {
    // Admin authority comes from the claim/allowlist, not from verification.
    const req = callable({uid: "a4", token: {email: "a@b.c", admin: true, email_verified: false}});
    assert.strictEqual(requireAdmin(req).uid, "a4");
  });
});

describe("download authorization is deliberately NOT re-gated on verification", () => {
  test("getDownloadUrl uses requireAuth, so entitlement stays the authority", () => {
    const fs = require("node:fs");
    const path = require("node:path");
    const src = fs.readFileSync(
      path.resolve(__dirname, "../src/downloads/download.ts"),
      "utf8"
    );
    // A regression guard: swapping this to requireVerifiedAuth would strand a
    // paying customer who later changes to an unverified address.
    assert.match(src, /const \{uid, email\} = requireAuth\(req\)/);
    assert.doesNotMatch(src, /requireVerifiedAuth/);
  });

  test("createCheckoutSession does use the verified guard", () => {
    const fs = require("node:fs");
    const path = require("node:path");
    const src = fs.readFileSync(
      path.resolve(__dirname, "../src/stripe/checkout.ts"),
      "utf8"
    );
    assert.match(src, /requireVerifiedAuth\(req\)/);
  });
});
