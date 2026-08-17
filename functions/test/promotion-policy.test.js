/**
 * Unit tests for the promotion-code policy.
 *
 * The status is what the admin screen reads to decide whether a code is still
 * worth handing out, so it has to agree with Stripe's own answer: a code Stripe
 * would refuse must never show as available.
 *
 * Run with:  npm --prefix functions test
 */

const {test, describe} = require("node:test");
const assert = require("node:assert");
const {
  ALLOWED_PERCENTS,
  MAX_BATCH,
  CODE_PATTERN,
  codeStatus,
  generateCode,
  isAllowedPercent,
} = require("../lib/stripe/promotion-policy");

const NOW = 1_760_000_000_000;
const HOUR = 60 * 60 * 1000;

/** A promotion code as Stripe reports it, with sane defaults. */
function promo(overrides = {}) {
  return {
    active: true,
    times_redeemed: 0,
    max_redemptions: 1,
    expires_at: null,
    ...overrides,
  };
}

describe("discount tiers", () => {
  test("only the five approved percentages are accepted", () => {
    assert.deepStrictEqual([...ALLOWED_PERCENTS], [10, 30, 50, 70, 100]);
    for (const p of ALLOWED_PERCENTS) assert.strictEqual(isAllowedPercent(p), true);
    for (const p of [0, 5, 15, 99, 101, -10, 10.5, NaN]) {
      assert.strictEqual(isAllowedPercent(p), false, `${p} must be refused`);
    }
  });
});

describe("generated codes", () => {
  test("carry the tier and a random suffix", () => {
    const code = generateCode(50, () => 0);
    assert.strictEqual(code, "4ICAD50-AAAAAA");
    assert.ok(CODE_PATTERN.test(code), "must satisfy the code pattern Stripe accepts");
  });

  test("avoid characters that are misread when typed by hand", () => {
    // 200 samples across the whole alphabet; O/0 and I/1 must never appear.
    for (let i = 0; i < 200; i++) {
      const suffix = generateCode(10).split("-")[1];
      assert.ok(!/[O0I1]/.test(suffix), `ambiguous character in ${suffix}`);
    }
  });

  test("are unique enough to hand out in batches", () => {
    const seen = new Set();
    for (let i = 0; i < MAX_BATCH * 50; i++) seen.add(generateCode(30));
    // 32^6 possibilities; a collision in 1000 draws would signal a broken RNG.
    assert.strictEqual(seen.size, MAX_BATCH * 50);
  });
});

describe("codeStatus", () => {
  test("a fresh single-use code is available", () => {
    assert.strictEqual(codeStatus(promo(), NOW), "active");
  });

  test("a redeemed single-use code reads as used — the case the screen exists for", () => {
    assert.strictEqual(
      codeStatus(promo({times_redeemed: 1, max_redemptions: 1}), NOW),
      "used"
    );
  });

  test("a partly-spent multi-use code is still available", () => {
    assert.strictEqual(
      codeStatus(promo({times_redeemed: 3, max_redemptions: 10}), NOW),
      "active"
    );
    assert.strictEqual(
      codeStatus(promo({times_redeemed: 10, max_redemptions: 10}), NOW),
      "used"
    );
  });

  test("an unlimited code never reads as used, however often it is redeemed", () => {
    assert.strictEqual(
      codeStatus(promo({times_redeemed: 999, max_redemptions: null}), NOW),
      "active"
    );
  });

  test("a lapsed expiry reads as expired", () => {
    assert.strictEqual(
      codeStatus(promo({expires_at: (NOW - HOUR) / 1000}), NOW),
      "expired"
    );
    assert.strictEqual(
      codeStatus(promo({expires_at: (NOW + HOUR) / 1000}), NOW),
      "active"
    );
  });

  test("used outranks expired — somebody redeemed it before it lapsed", () => {
    assert.strictEqual(
      codeStatus(
        promo({times_redeemed: 1, max_redemptions: 1, expires_at: (NOW - HOUR) / 1000}),
        NOW
      ),
      "used"
    );
  });

  test("a switched-off code reads as disabled, not available", () => {
    assert.strictEqual(codeStatus(promo({active: false}), NOW), "disabled");
  });

  test("a switched-off code that was already redeemed still reads as used", () => {
    assert.strictEqual(
      codeStatus(promo({active: false, times_redeemed: 1, max_redemptions: 1}), NOW),
      "used"
    );
  });
});
