/**
 * Unit tests for the 48-hour web-app trial policy.
 *
 * These exercise the policy directly rather than through a deployed function,
 * because the token format and the window arithmetic are the security boundary:
 * `verifyWebTrial` refuses before it reads any Firestore state, and the trial
 * anchor is what stops a visitor from restarting their own clock.
 *
 * Run with:  npm --prefix functions test
 */

const {test, describe} = require("node:test");
const assert = require("node:assert");
const {
  TRIAL_WINDOW_MS,
  OWNER_TOKEN_TTL_MS,
  trialWindow,
  signTrialToken,
  verifyTrialToken,
  buildLaunchUrl,
} = require("../lib/trials/trial-policy");

const SECRET = "test-signing-key-not-a-real-secret";
const T0 = 1_760_000_000_000; // fixed clock; the policy never reads Date.now()

function trialPayload(overrides = {}) {
  return {
    v: 1,
    kind: "trial",
    uid: "u-1",
    productKey: "4icad_windows",
    iat: Math.floor(T0 / 1000),
    exp: Math.floor((T0 + TRIAL_WINDOW_MS) / 1000),
    ...overrides,
  };
}

describe("trialWindow", () => {
  test("is exactly 48 hours from the first launch", () => {
    assert.strictEqual(TRIAL_WINDOW_MS, 48 * 60 * 60 * 1000);
    const w = trialWindow(T0, T0);
    assert.strictEqual(w.expiresAtMs, T0 + 48 * 60 * 60 * 1000);
    assert.strictEqual(w.expired, false);
  });

  test("counts down from the anchor, so re-launching does not extend it", () => {
    const later = trialWindow(T0, T0 + 40 * 60 * 60 * 1000);
    assert.strictEqual(later.remainingMs, 8 * 60 * 60 * 1000);
    assert.strictEqual(later.expiresAtMs, trialWindow(T0, T0).expiresAtMs);
  });

  test("expires at the boundary, not after it", () => {
    assert.strictEqual(trialWindow(T0, T0 + TRIAL_WINDOW_MS - 1).expired, false);
    assert.strictEqual(trialWindow(T0, T0 + TRIAL_WINDOW_MS).expired, true);
  });

  test("reports zero rather than a negative countdown once elapsed", () => {
    const w = trialWindow(T0, T0 + 100 * 60 * 60 * 1000);
    assert.strictEqual(w.remainingMs, 0);
    assert.strictEqual(w.expired, true);
  });
});

describe("trial tokens", () => {
  test("a freshly signed token verifies within its window", () => {
    const token = signTrialToken(trialPayload(), SECRET);
    const check = verifyTrialToken(token, SECRET, T0 + 1000);
    assert.strictEqual(check.valid, true);
    assert.strictEqual(check.payload.uid, "u-1");
    assert.strictEqual(check.payload.kind, "trial");
  });

  test("a token signed with a different key is refused", () => {
    const token = signTrialToken(trialPayload(), "some-other-key");
    const check = verifyTrialToken(token, SECRET, T0);
    assert.strictEqual(check.valid, false);
    assert.strictEqual(check.reason, "bad_signature");
  });

  test("an edited payload no longer matches its signature", () => {
    const token = signTrialToken(trialPayload(), SECRET);
    const [body, sig] = token.split(".");
    const decoded = JSON.parse(
      Buffer.from(body.replace(/-/g, "+").replace(/_/g, "/"), "base64").toString("utf8")
    );
    // Forge a far-future expiry — the exact attack the signature exists to stop.
    decoded.exp = Math.floor((T0 + 365 * 24 * 60 * 60 * 1000) / 1000);
    const forgedBody = Buffer.from(JSON.stringify(decoded), "utf8")
      .toString("base64")
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");

    const check = verifyTrialToken(`${forgedBody}.${sig}`, SECRET, T0);
    assert.strictEqual(check.valid, false);
    assert.strictEqual(check.reason, "bad_signature");
  });

  test("a trial token stops verifying once the 48 hours elapse", () => {
    const token = signTrialToken(trialPayload(), SECRET);
    const check = verifyTrialToken(token, SECRET, T0 + TRIAL_WINDOW_MS + 1);
    assert.strictEqual(check.valid, false);
    assert.strictEqual(check.reason, "trial_expired");
  });

  test("an owner token reports plain expiry, not a spent trial", () => {
    const token = signTrialToken(
      trialPayload({kind: "owner", exp: Math.floor((T0 + OWNER_TOKEN_TTL_MS) / 1000)}),
      SECRET
    );
    assert.strictEqual(verifyTrialToken(token, SECRET, T0).valid, true);
    const later = verifyTrialToken(token, SECRET, T0 + OWNER_TOKEN_TTL_MS + 1);
    assert.strictEqual(later.valid, false);
    assert.strictEqual(later.reason, "token_expired");
  });

  test("garbage is rejected as malformed rather than throwing", () => {
    for (const bad of ["", "not-a-token", "a.b.c", ".", "eyJhIjoxfQ"]) {
      const check = verifyTrialToken(bad, SECRET, T0);
      assert.strictEqual(check.valid, false, `expected ${JSON.stringify(bad)} to be refused`);
    }
  });

  test("a token from an unknown format version is refused", () => {
    const token = signTrialToken(trialPayload({v: 2}), SECRET);
    const check = verifyTrialToken(token, SECRET, T0);
    assert.strictEqual(check.valid, false);
    assert.strictEqual(check.reason, "malformed");
  });
});

describe("buildLaunchUrl", () => {
  test("attaches the token to the configured web app", () => {
    const url = buildLaunchUrl("https://icad-75d53.web.app", "tok123");
    assert.strictEqual(url, "https://icad-75d53.web.app/?trial=tok123");
  });

  test("preserves an existing path and query", () => {
    const url = buildLaunchUrl("https://icad-75d53.web.app/app?ref=site", "tok123");
    assert.ok(url.startsWith("https://icad-75d53.web.app/app?"));
    assert.ok(url.includes("ref=site"));
    assert.ok(url.includes("trial=tok123"));
  });

  test("refuses to hand a token to a non-https destination", () => {
    assert.throws(() => buildLaunchUrl("http://icad-75d53.web.app", "tok123"));
  });
});
