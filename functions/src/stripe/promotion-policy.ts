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

/** How many spendable codes each tier should hold. */
export const STOCK_PER_TIER = 5;

export interface TierStock {
  percentOff: number;
  available: number;
  used: number;
  /** Expired or switched off — neither spendable nor spent. */
  unusable: number;
  /** How many to create to bring the tier back up to target. */
  missing: number;
}

/**
 * Summarises the stock an admin has left to hand out, per tier.
 *
 * "Available" deliberately counts only codes that can still be spent right now:
 * an expired or disabled code is neither something to send someone nor evidence
 * that a customer used one, so it is reported separately rather than padding
 * either figure.
 */
export function summariseStock(
  codes: Array<{percentOff: number | null; status: CodeStatus}>,
  target: number = STOCK_PER_TIER
): TierStock[] {
  return ALLOWED_PERCENTS.map((percentOff) => {
    const mine = codes.filter((c) => c.percentOff === percentOff);
    const available = mine.filter((c) => c.status === "active").length;
    const used = mine.filter((c) => c.status === "used").length;
    return {
      percentOff,
      available,
      used,
      unusable: mine.length - available - used,
      missing: Math.max(0, target - available),
    };
  });
}

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
