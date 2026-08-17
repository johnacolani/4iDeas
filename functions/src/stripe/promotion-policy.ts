import type Stripe from "stripe";

/**
 * Pure promotion-code policy: which discounts are allowed, what a generated
 * code looks like, and whether a code can still be spent.
 *
 * Side-effect free — no Admin SDK, no Stripe client — so the rules can be unit
 * tested directly, the same way `auth-guards` and `trial-policy` are.
 */

/** The approved discount tiers. Anything else is rejected server-side. */
export const ALLOWED_PERCENTS = [10, 30, 50, 70, 100] as const;

/** Most codes an admin can mint in one call. */
export const MAX_BATCH = 20;

/**
 * Alphabet for generated codes: no O/0, I/1 or similar look-alikes, because
 * these are read aloud, typed off a screenshot, and copied by hand.
 */
const CODE_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

/** `4ICAD50-K7QF2P` — the tier stays legible, the suffix makes it unique. */
export function generateCode(
  percentOff: number,
  random: () => number = Math.random
): string {
  let suffix = "";
  for (let i = 0; i < 6; i++) {
    suffix += CODE_ALPHABET[Math.floor(random() * CODE_ALPHABET.length)];
  }
  return `4ICAD${percentOff}-${suffix}`;
}

/** The shape Stripe validates a customer-supplied code against. */
export const CODE_PATTERN = /^[A-Z0-9_-]{3,40}$/;

export function isAllowedPercent(percentOff: number): boolean {
  return (ALLOWED_PERCENTS as readonly number[]).includes(percentOff);
}

/**
 * What an admin actually needs to know about a code at a glance.
 *
 * Derived, never stored: Stripe holds the redemption count and the expiry, and
 * a status written into our own database could disagree with the only system
 * that actually accepts or refuses a code.
 */
export type CodeStatus = "active" | "used" | "expired" | "disabled";

/** Just the fields the status depends on, so tests need no Stripe fixtures. */
export type StatusInput = Pick<
  Stripe.PromotionCode,
  "active" | "times_redeemed" | "max_redemptions" | "expires_at"
>;

export function codeStatus(promo: StatusInput, nowMs: number): CodeStatus {
  const spent =
    promo.max_redemptions !== null &&
    promo.max_redemptions !== undefined &&
    promo.times_redeemed >= promo.max_redemptions;
  // Spent before expired: "used" is the more useful fact when both are true —
  // it says a customer redeemed it, where "expired" says nobody did in time.
  if (spent) return "used";
  if (promo.expires_at && promo.expires_at * 1000 <= nowMs) return "expired";
  if (!promo.active) return "disabled";
  return "active";
}
