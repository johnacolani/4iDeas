import {onCall, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import type Stripe from "stripe";
import {COL, PRODUCT_KEY, STRIPE_SECRET_KEY, db, requireAdmin, stripeClient} from "../core";

/** The approved discount tiers. Anything else is rejected server-side. */
const ALLOWED_PERCENTS = [10, 30, 50, 70, 100] as const;

/**
 * Creates a real Stripe Coupon + Promotion Code pair.
 *
 * Everything here is Stripe state — nothing about a discount is stored in
 * Firestore and then trusted. Checkout remains the sole authority on what a
 * code is worth.
 */
export const createPromotionCode = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    requireAdmin(req);

    const code = String(req.data?.code ?? "").trim().toUpperCase();
    const percentOff = Number(req.data?.percentOff);
    const maxRedemptions = req.data?.maxRedemptions ? Number(req.data.maxRedemptions) : undefined;
    const expiresAt = req.data?.expiresAt ? Number(req.data.expiresAt) : undefined;
    const firstTimeOnly = req.data?.firstTimeTransactionOnly === true;

    if (!/^[A-Z0-9_-]{3,40}$/.test(code)) {
      throw new HttpsError("invalid-argument", "Use 3–40 characters: letters, digits, - or _.");
    }
    if (!ALLOWED_PERCENTS.includes(percentOff as typeof ALLOWED_PERCENTS[number])) {
      throw new HttpsError(
        "invalid-argument",
        `Discount must be one of ${ALLOWED_PERCENTS.join(", ")} percent.`
      );
    }
    if (maxRedemptions !== undefined && (!Number.isInteger(maxRedemptions) || maxRedemptions < 1)) {
      throw new HttpsError("invalid-argument", "Maximum redemptions must be a positive whole number.");
    }
    if (expiresAt !== undefined && expiresAt * 1000 <= Date.now()) {
      throw new HttpsError("invalid-argument", "The expiry date must be in the future.");
    }

    const stripe = stripeClient();

    // Scope the coupon to this product so a code can't be spent on anything else.
    const cfg = await db.collection(COL.productConfig).doc(PRODUCT_KEY).get();
    const stripeProductId = cfg.data()?.stripeProductId as string | undefined;

    const coupon = await stripe.coupons.create({
      percent_off: percentOff,
      duration: "once",
      name: `${percentOff}% off 4iCAD for Windows`,
      ...(stripeProductId ? {applies_to: {products: [stripeProductId]}} : {}),
      metadata: {productKey: PRODUCT_KEY, createdBy: "4ideasapp-admin"},
    });

    let promo: Stripe.PromotionCode;
    try {
      promo = await stripe.promotionCodes.create({
        coupon: coupon.id,
        code,
        active: true,
        ...(maxRedemptions ? {max_redemptions: maxRedemptions} : {}),
        ...(expiresAt ? {expires_at: expiresAt} : {}),
        ...(firstTimeOnly ? {restrictions: {first_time_transaction: true}} : {}),
        metadata: {productKey: PRODUCT_KEY},
      });
    } catch (err) {
      // Don't leave an orphan coupon behind if the code was already taken.
      await stripe.coupons.del(coupon.id).catch(() => undefined);
      throw new HttpsError("already-exists", `Could not create code ${code}. It may already exist.`);
    }

    logger.info("promotion code created", {code, percentOff});
    return {
      id: promo.id,
      code: promo.code,
      percentOff,
      active: promo.active,
      maxRedemptions: promo.max_redemptions ?? null,
      expiresAt: promo.expires_at ?? null,
      timesRedeemed: promo.times_redeemed,
    };
  }
);

/** Lists live promotion codes straight from Stripe — Firestore holds no copy. */
export const listPromotionCodes = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    requireAdmin(req);
    const stripe = stripeClient();
    const list = await stripe.promotionCodes.list({limit: 100, expand: ["data.coupon"]});
    return {
      codes: list.data.map((p) => ({
        id: p.id,
        code: p.code,
        active: p.active,
        percentOff: typeof p.coupon === "string" ? null : p.coupon.percent_off,
        maxRedemptions: p.max_redemptions ?? null,
        timesRedeemed: p.times_redeemed,
        expiresAt: p.expires_at ?? null,
        firstTimeOnly: p.restrictions?.first_time_transaction ?? false,
      })),
    };
  }
);

/**
 * Activates or deactivates a code. Stripe only permits toggling `active` on a
 * promotion code — the discount value itself is immutable, which is the
 * behaviour we want for anything already in customers' hands.
 */
export const setPromotionCodeActive = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    requireAdmin(req);
    const id = String(req.data?.id ?? "");
    const active = req.data?.active === true;
    if (!id) throw new HttpsError("invalid-argument", "A promotion code id is required.");

    const promo = await stripeClient().promotionCodes.update(id, {active});
    logger.info("promotion code toggled", {id, active});
    return {id: promo.id, code: promo.code, active: promo.active};
  }
);
