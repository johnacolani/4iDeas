import {onRequest} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import type Stripe from "stripe";
import {
  COL,
  FieldValue,
  STRIPE_SECRET_KEY,
  STRIPE_WEBHOOK_SECRET,
  db,
  entitlementId,
  stripeClient,
} from "../core";

/**
 * A Checkout Session is fulfillable when Stripe says the money question is
 * settled. That is `paid` for a normal purchase and `no_payment_required` for a
 * fully-discounted (100% off) order — which is a real order, not a bypass.
 * Anything else (notably `unpaid`) must never grant an entitlement.
 */
function isFulfillable(session: Stripe.Checkout.Session): boolean {
  return session.payment_status === "paid" || session.payment_status === "no_payment_required";
}

/** Pull promotion/discount detail out of an expanded session, if any was used. */
function discountInfo(session: Stripe.Checkout.Session) {
  const discounts = (session.discounts ?? []) as Stripe.Checkout.Session.Discount[];
  const first = discounts[0];
  const promo = first?.promotion_code;
  const coupon = first?.coupon;
  return {
    promotionCodeId: typeof promo === "string" ? promo : promo?.id ?? null,
    promotionCode: typeof promo === "string" ? null : promo?.code ?? null,
    couponId: typeof coupon === "string" ? coupon : coupon?.id ?? null,
    couponName: typeof coupon === "string" ? null : coupon?.name ?? null,
    percentOff: typeof coupon === "string" ? null : coupon?.percent_off ?? null,
    amountOff: typeof coupon === "string" ? null : coupon?.amount_off ?? null,
    amountDiscount: session.total_details?.amount_discount ?? 0,
  };
}

/**
 * Writes the order and entitlement for a fulfillable session.
 *
 * Idempotency has two layers: the event id is claimed in a transaction before
 * any work happens, and the order document is keyed by Checkout Session id. A
 * Stripe retry therefore cannot produce a duplicate order or a second
 * entitlement, no matter how many times it is delivered.
 */
async function fulfill(session: Stripe.Checkout.Session, eventId: string, eventType: string) {
  const uid = (session.metadata?.firebaseUid ?? session.client_reference_id) as string | undefined;
  const productKey = session.metadata?.productKey as string | undefined;

  if (!uid || !productKey) {
    logger.error("session missing firebaseUid/productKey metadata", {sessionId: session.id});
    return;
  }
  if (!isFulfillable(session)) {
    logger.info("session not fulfillable; no entitlement granted", {
      sessionId: session.id,
      paymentStatus: session.payment_status,
    });
    return;
  }

  const d = discountInfo(session);
  const orderRef = db.collection(COL.productOrders).doc(session.id);
  const entRef = db.collection(COL.entitlements).doc(entitlementId(uid, productKey));

  await db.runTransaction(async (tx) => {
    const existing = await tx.get(orderRef);

    tx.set(
      orderRef,
      {
        uid,
        productKey,
        customerEmail:
          session.customer_details?.email ?? session.customer_email ?? null,
        stripeCustomerId:
          typeof session.customer === "string" ? session.customer : session.customer?.id ?? null,
        checkoutSessionId: session.id,
        paymentIntentId:
          typeof session.payment_intent === "string"
            ? session.payment_intent
            : session.payment_intent?.id ?? null,
        // amount_subtotal is the pre-discount total; amount_total is what was charged.
        originalAmount: session.amount_subtotal ?? null,
        amountPaid: session.amount_total ?? 0,
        currency: session.currency ?? null,
        amountDiscount: d.amountDiscount,
        promotionCode: d.promotionCode,
        promotionCodeId: d.promotionCodeId,
        couponId: d.couponId,
        couponName: d.couponName,
        percentOff: d.percentOff,
        paymentStatus: session.payment_status,
        status: "completed",
        // A 100%-off order is a real order that simply required no payment.
        isFreeRedemption: (session.amount_total ?? 0) === 0,
        purchasedAt: existing.exists
          ? existing.data()?.purchasedAt ?? FieldValue.serverTimestamp()
          : FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        lastEventId: eventId,
        lastEventType: eventType,
      },
      {merge: true}
    );

    // Entitlement is product-scoped, not release-scoped, so a buyer keeps
    // access to every future Current release without a new purchase.
    tx.set(
      entRef,
      {
        uid,
        productKey,
        active: true,
        source: "stripe_checkout",
        orderId: session.id,
        grantedAt: FieldValue.serverTimestamp(),
      },
      {merge: true}
    );
  });

  logger.info("order fulfilled", {uid, productKey, sessionId: session.id});
}

/**
 * Stripe webhook endpoint. This — not `/4icad/success` — is what grants access.
 *
 * Requires the raw request body for signature verification, which
 * `onRequest` preserves via `req.rawBody`.
 */
export const stripeWebhook = onRequest(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET], cors: false},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    const signature = req.headers["stripe-signature"];
    if (!signature || typeof signature !== "string") {
      res.status(400).send("Missing signature");
      return;
    }

    const stripe = stripeClient();
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(
        req.rawBody,
        signature,
        STRIPE_WEBHOOK_SECRET.value()
      );
    } catch (err) {
      // Never echo the error detail to the caller.
      logger.warn("webhook signature verification failed");
      res.status(400).send("Invalid signature");
      return;
    }

    // Claim the event id first. If it is already claimed, this is a retry of
    // something we finished, so acknowledge without repeating the work.
    const eventRef = db.collection(COL.stripeEvents).doc(event.id);
    const fresh = await db.runTransaction(async (tx) => {
      const snap = await tx.get(eventRef);
      if (snap.exists && snap.data()?.status === "processed") return false;
      tx.set(
        eventRef,
        {
          eventId: event.id,
          type: event.type,
          status: "processing",
          receivedAt: FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
      return true;
    });

    if (!fresh) {
      logger.info("duplicate webhook ignored", {eventId: event.id, type: event.type});
      res.status(200).send("Already processed");
      return;
    }

    try {
      switch (event.type) {
      case "checkout.session.completed":
      case "checkout.session.async_payment_succeeded": {
        // Re-fetch with discounts expanded — the event payload does not carry
        // the coupon/promotion objects we record on the order.
        const raw = event.data.object as Stripe.Checkout.Session;
        const session = await stripe.checkout.sessions.retrieve(raw.id, {
          expand: ["discounts.promotion_code", "discounts.coupon", "payment_intent"],
        });
        await fulfill(session, event.id, event.type);
        break;
      }
      case "checkout.session.async_payment_failed":
      case "checkout.session.expired": {
        const session = event.data.object as Stripe.Checkout.Session;
        await db.collection(COL.productOrders).doc(session.id).set(
          {
            checkoutSessionId: session.id,
            uid: session.metadata?.firebaseUid ?? session.client_reference_id ?? null,
            productKey: session.metadata?.productKey ?? null,
            status: event.type === "checkout.session.expired" ? "expired" : "failed",
            paymentStatus: session.payment_status,
            updatedAt: FieldValue.serverTimestamp(),
            lastEventId: event.id,
            lastEventType: event.type,
          },
          {merge: true}
        );
        break;
      }
      default:
        logger.debug("unhandled event type", {type: event.type});
      }

      await eventRef.set(
        {status: "processed", processedAt: FieldValue.serverTimestamp()},
        {merge: true}
      );
      res.status(200).send("ok");
    } catch (err) {
      // Leave the event un-processed so Stripe's retry can complete it.
      await eventRef.set(
        {status: "error", error: String(err), erroredAt: FieldValue.serverTimestamp()},
        {merge: true}
      );
      logger.error("webhook handling failed", {eventId: event.id, type: event.type});
      res.status(500).send("Handler error");
    }
  }
);
