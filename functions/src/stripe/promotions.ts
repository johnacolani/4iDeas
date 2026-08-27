import {onCall, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import type Stripe from "stripe";
import {COL, STRIPE_SECRET_KEY, db, requireAdmin, stripeClient} from "../core";

import {
  ALLOWED_PERCENTS,
  CODE_PATTERN,
  MAX_BATCH,
  STOCK_PER_TIER,
  codeStatus,
  generateCode,
  isAllowedPercent,
  summariseStock,
} from "./promotion-policy";

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
    const {email: adminEmail} = requireAdmin(req);

    const requested = String(req.data?.code ?? "").trim().toUpperCase();
    const percentOff = Number(req.data?.percentOff);
    const count = req.data?.count ? Number(req.data.count) : 1;
    const maxRedemptions = req.data?.maxRedemptions ? Number(req.data.maxRedemptions) : undefined;
    const expiresAt = req.data?.expiresAt ? Number(req.data.expiresAt) : undefined;
    const firstTimeOnly = req.data?.firstTimeTransactionOnly === true;
    const note = String(req.data?.note ?? "").trim().slice(0, 200);

    if (!Number.isInteger(count) || count < 1 || count > MAX_BATCH) {
      throw new HttpsError("invalid-argument", `Generate between 1 and ${MAX_BATCH} codes.`);
    }
    // A named code is one code by definition — a batch has to be generated.
    if (requested && count > 1) {
      throw new HttpsError(
        "invalid-argument",
        "Leave the code blank to generate a batch, or ask for one code."
      );
    }
    if (requested && !CODE_PATTERN.test(requested)) {
      throw new HttpsError("invalid-argument", "Use 3–40 characters: letters, digits, - or _.");
    }
    if (!isAllowedPercent(percentOff)) {
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

    // One unrestricted coupon carries the discount, so the same code works
    // for every 4iCAD platform sold through this Stripe account.
    const coupon = await stripe.coupons.create({
      percent_off: percentOff,
      duration: "once",
      name: `${percentOff}% off 4iCAD`,
      metadata: {productScope: "all", createdBy: "4ideasapp-admin"},
    });

    const created: Stripe.PromotionCode[] = [];
    try {
      for (let i = 0; i < count; i++) {
        const code = requested || generateCode(percentOff);
        created.push(
          await stripe.promotionCodes.create({
            coupon: coupon.id,
            code,
            active: true,
            ...(maxRedemptions ? {max_redemptions: maxRedemptions} : {}),
            ...(expiresAt ? {expires_at: expiresAt} : {}),
            ...(firstTimeOnly ? {restrictions: {first_time_transaction: true}} : {}),
            metadata: {
              productScope: "all",
              ...(note ? {note} : {}),
              ...(adminEmail ? {issuedBy: adminEmail} : {}),
            },
          })
        );
      }
    } catch (err) {
      if (created.length === 0) {
        // Don't leave an orphan coupon behind if the code was already taken.
        await stripe.coupons.del(coupon.id).catch(() => undefined);
        throw new HttpsError(
          "already-exists",
          requested ?
            `Could not create code ${requested}. It may already exist.` :
            "Could not generate the codes. Please try again."
        );
      }
      // A partial batch is kept: the codes that exist are real and usable, and
      // silently deleting them would be worse than reporting fewer than asked.
      logger.warn("promotion code batch partially created", {
        requested: count,
        created: created.length,
      });
    }

    const now = Date.now();
    logger.info("promotion codes created", {count: created.length, percentOff});
    return {
      codes: created.map((promo) => ({
        id: promo.id,
        code: promo.code,
        percentOff,
        active: promo.active,
        status: codeStatus(promo, now),
        maxRedemptions: promo.max_redemptions ?? null,
        expiresAt: promo.expires_at ?? null,
        timesRedeemed: promo.times_redeemed,
        note: note || null,
      })),
    };
  }
);

/**
 * Lists live promotion codes straight from Stripe — Firestore holds no copy of
 * a discount — and says who spent each one.
 *
 * The redemption count is Stripe's; the identity behind it is ours. Joining the
 * two is the only way to answer "who used this code", because Stripe knows a
 * customer while the admin thinks in terms of the person they handed a code to.
 * Only redeemed codes are looked up, so an unused stock costs no reads.
 */
export const listPromotionCodes = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    requireAdmin(req);
    const stripe = stripeClient();
    const list = await stripe.promotionCodes.list({limit: 100, expand: ["data.coupon"]});
    const now = Date.now();

    const redemptions = await Promise.all(
      list.data.map(async (p) => {
        if (p.times_redeemed < 1) return null;
        const orders = await db
          .collection(COL.productOrders)
          .where("promotionCodeId", "==", p.id)
          .limit(1)
          .get();
        if (orders.empty) return null;
        const order = orders.docs[0].data();
        return {
          email: (order.customerEmail as string | undefined) ?? null,
          uid: (order.uid as string | undefined) ?? null,
          sessionId: orders.docs[0].id,
          amountPaid: (order.amountPaid as number | undefined) ?? null,
          amountDiscount: (order.amountDiscount as number | undefined) ?? null,
          currency: (order.currency as string | undefined) ?? null,
          at: (order.purchasedAt as FirebaseFirestore.Timestamp | undefined)?.toMillis() ?? null,
        };
      })
    );

    return {
      codes: list.data.map((p, i) => ({
        id: p.id,
        code: p.code,
        active: p.active,
        status: codeStatus(p, now),
        percentOff: typeof p.coupon === "string" ? null : p.coupon.percent_off,
        maxRedemptions: p.max_redemptions ?? null,
        timesRedeemed: p.times_redeemed,
        expiresAt: p.expires_at ?? null,
        createdAt: p.created * 1000,
        firstTimeOnly: p.restrictions?.first_time_transaction ?? false,
        note: p.metadata?.note ?? null,
        issuedBy: p.metadata?.issuedBy ?? null,
        sentTo: p.metadata?.sentTo ?? null,
        sentAt: p.metadata?.sentAt ? Number(p.metadata.sentAt) : null,
        redeemedBy: redemptions[i],
      })),
      // The counts the admin screen leads with: how many of each tier are left
      // to give away, and how many customers have spent one.
      stock: summariseStock(
        list.data.map((p) => ({
          percentOff: typeof p.coupon === "string" ? null : p.coupon.percent_off,
          status: codeStatus(p, now),
        }))
      ),
    };
  }
);

/**
 * Tops every tier back up to five spendable codes.
 *
 * This is the stock an admin hands out one at a time, so the useful operation
 * is "make sure I have five of each again", not "create one more". Idempotent:
 * a tier that already holds five is left alone, so pressing the button twice
 * does not mint ten.
 */
export const restockPromotionCodes = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    const {email: adminEmail} = requireAdmin(req);
    const target = req.data?.target ? Number(req.data.target) : STOCK_PER_TIER;
    if (!Number.isInteger(target) || target < 1 || target > MAX_BATCH) {
      throw new HttpsError("invalid-argument", `Keep between 1 and ${MAX_BATCH} codes per tier.`);
    }

    const stripe = stripeClient();
    const now = Date.now();

    const existing = await stripe.promotionCodes.list({limit: 100, expand: ["data.coupon"]});
    // Product-restricted legacy coupons do not count as reusable stock. This
    // ensures restocking creates codes that work for Windows, Web, Linux, and
    // future products, while leaving previously issued codes intact.
    const allProductCodes = existing.data.filter((p) => {
      if (typeof p.coupon === "string") return false;
      const products = p.coupon.applies_to?.products;
      return !products || products.length === 0;
    });
    const stock = summariseStock(
      allProductCodes.map((p) => ({
        percentOff: typeof p.coupon === "string" ? null : p.coupon.percent_off,
        status: codeStatus(p, now),
      })),
      target
    );

    let created = 0;
    for (const tier of stock) {
      if (tier.missing < 1) continue;

      // One coupon per top-up carries the discount; its codes point at it.
      const coupon = await stripe.coupons.create({
        percent_off: tier.percentOff,
        duration: "once",
        name: `${tier.percentOff}% off 4iCAD`,
        metadata: {productScope: "all", createdBy: "4ideasapp-admin"},
      });

      for (let i = 0; i < tier.missing; i++) {
        try {
          await stripe.promotionCodes.create({
            coupon: coupon.id,
            code: generateCode(tier.percentOff),
            active: true,
            // Single-use: a code handed to one person must stop working once
            // that person has used it, or the counts here mean nothing.
            max_redemptions: 1,
            metadata: {
              productScope: "all",
              ...(adminEmail ? {issuedBy: adminEmail} : {}),
            },
          });
          created++;
        } catch (err) {
          // A collision on the random suffix is not worth failing the restock.
          logger.warn("promotion code creation skipped", {percentOff: tier.percentOff});
        }
      }
    }

    logger.info("promotion stock topped up", {created, target});
    return {created, target};
  }
);

/**
 * Records who a code was sent to.
 *
 * Kept on the Stripe promotion code itself rather than in a second database, so
 * the recipient travels with the code and cannot drift out of sync with it.
 * This does not restrict redemption — it is a label, so the admin can see who
 * was given what, and later compare it with who actually spent it.
 */
export const assignPromotionCode = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    requireAdmin(req);
    const id = String(req.data?.id ?? "");
    const email = String(req.data?.sentTo ?? "").trim().toLowerCase();
    if (!id) throw new HttpsError("invalid-argument", "A promotion code id is required.");
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
      throw new HttpsError("invalid-argument", "Enter a valid email address.");
    }

    const promo = await stripeClient().promotionCodes.update(id, {
      metadata: {sentTo: email, sentAt: String(Date.now())},
    });
    logger.info("promotion code assigned", {id, code: promo.code});
    return {id: promo.id, code: promo.code, sentTo: email};
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
