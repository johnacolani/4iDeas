import {onRequest} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import type Stripe from "stripe";
import {
  COL,
  FieldValue,
  LINUX_PRODUCT_KEY,
  PRODUCT_KEY,
  STRIPE_SECRET_KEY,
  STRIPE_WEBHOOK_SECRET,
  db,
  entitlementId,
  stripeClient,
} from "../core";
import {
  isDevicePlatform,
  isLicensePlan,
  type DevicePlatform,
} from "../licensing/license-policy";
import {createOrUpdateLicense} from "../licensing/license-store";

/**
 * A Checkout Session is fulfillable when Stripe says the money question is
 * settled. That is `paid` for a normal purchase and `no_payment_required` for a
 * fully-discounted (100% off) order — which is a real order, not a bypass.
 * Anything else (notably `unpaid`) must never grant access.
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

function downloadableProductForPrimaryPlatform(
  platform: DevicePlatform
): string | null {
  if (platform === "windows") return PRODUCT_KEY;
  if (platform === "linux") return LINUX_PRODUCT_KEY;
  return null;
}

function stripeCustomerId(session: Stripe.Checkout.Session): string | null {
  return typeof session.customer === "string"
    ? session.customer
    : session.customer?.id ?? null;
}

function paymentIntentId(session: Stripe.Checkout.Session): string | null {
  return typeof session.payment_intent === "string"
    ? session.payment_intent
    : session.payment_intent?.id ?? null;
}

function customerEmail(session: Stripe.Checkout.Session): string | null {
  return session.customer_details?.email ?? session.customer_email ?? null;
}

/**
 * New license purchase fulfillment. A paid license is created first, then the
 * order and any compatible protected-download entitlement are persisted.
 * Retries are safe: license creation preserves counters and order ids are keyed
 * by Checkout Session id.
 */
async function fulfillLicensePurchase(
  session: Stripe.Checkout.Session,
  eventId: string,
  eventType: string,
  uid: string
) {
  const rawPlan = session.metadata?.licensePlan;
  const rawPlatform = session.metadata?.primaryPlatform;
  if (!isLicensePlan(rawPlan) || !isDevicePlatform(rawPlatform)) {
    throw new Error(`Malformed license checkout metadata for ${session.id}`);
  }

  const d = discountInfo(session);
  const legacyProductKey = downloadableProductForPrimaryPlatform(rawPlatform);

  await createOrUpdateLicense({
    ownerUid: uid,
    ownerEmail: customerEmail(session),
    plan: rawPlan,
    primaryPlatform: rawPlatform,
    source: "stripe_checkout",
    orderId: session.id,
    stripeCustomerId: stripeCustomerId(session),
  });

  const orderRef = db.collection(COL.productOrders).doc(session.id);
  await db.runTransaction(async (tx) => {
    const existing = await tx.get(orderRef);
    tx.set(
      orderRef,
      {
        uid,
        purchaseKind: "4icad_license",
        licensePlan: rawPlan,
        primaryPlatform: rawPlatform,
        productKey: legacyProductKey,
        customerEmail: customerEmail(session),
        stripeCustomerId: stripeCustomerId(session),
        checkoutSessionId: session.id,
        paymentIntentId: paymentIntentId(session),
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

    // Windows/Linux still use the existing protected-download flow. Mirroring
    // the license into the legacy product entitlement keeps that flow working
    // while the website UI is migrated to the new plan model.
    if (legacyProductKey) {
      const entRef = db
        .collection(COL.entitlements)
        .doc(entitlementId(uid, legacyProductKey));
      tx.set(
        entRef,
        {
          uid,
          productKey: legacyProductKey,
          active: true,
          source: "4icad_license",
          licensePlan: rawPlan,
          primaryPlatform: rawPlatform,
          orderId: session.id,
          grantedAt: FieldValue.serverTimestamp(),
        },
        {merge: true}
      );
    }
  });

  logger.info("license order fulfilled", {
    uid,
    licensePlan: rawPlan,
    primaryPlatform: rawPlatform,
    sessionId: session.id,
  });
}

/** Existing platform-product purchase fulfillment retained during migration. */
async function fulfillLegacyProductPurchase(
  session: Stripe.Checkout.Session,
  eventId: string,
  eventType: string,
  uid: string,
  productKey: string
) {
  const d = discountInfo(session);
  const orderRef = db.collection(COL.productOrders).doc(session.id);
  const entRef = db.collection(COL.entitlements).doc(entitlementId(uid, productKey));

  await db.runTransaction(async (tx) => {
    const existing = await tx.get(orderRef);

    tx.set(
      orderRef,
      {
        uid,
        purchaseKind: "legacy_product",
        productKey,
        customerEmail: customerEmail(session),
        stripeCustomerId: stripeCustomerId(session),
        checkoutSessionId: session.id,
        paymentIntentId: paymentIntentId(session),
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

  logger.info("legacy product order fulfilled", {
    uid,
    productKey,
    sessionId: session.id,
  });
}

async function fulfill(session: Stripe.Checkout.Session, eventId: string, eventType: string) {
  const uid = (session.metadata?.firebaseUid ?? session.client_reference_id) as
    | string
    | undefined;

  if (!uid) {
    throw new Error(`Session ${session.id} missing firebase uid metadata`);
  }
  if (!isFulfillable(session)) {
    logger.info("session not fulfillable; no access granted", {
      sessionId: session.id,
      paymentStatus: session.payment_status,
    });
    return;
  }

  if (session.metadata?.purchaseKind === "4icad_license") {
    await fulfillLicensePurchase(session, eventId, eventType, uid);
    return;
  }

  const productKey = session.metadata?.productKey;
  if (!productKey) {
    throw new Error(`Session ${session.id} missing productKey metadata`);
  }
  await fulfillLegacyProductPurchase(session, eventId, eventType, uid, productKey);
}

/**
 * Stripe webhook endpoint. This — not any success page — is what grants access.
 * Requires the raw request body for signature verification.
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
    } catch {
      logger.warn("webhook signature verification failed");
      res.status(400).send("Invalid signature");
      return;
    }

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
            purchaseKind: session.metadata?.purchaseKind ?? "legacy_product",
            productKey: session.metadata?.productKey ?? null,
            licensePlan: session.metadata?.licensePlan ?? null,
            primaryPlatform: session.metadata?.primaryPlatform ?? null,
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
      await eventRef.set(
        {status: "error", error: String(err), erroredAt: FieldValue.serverTimestamp()},
        {merge: true}
      );
      logger.error("webhook handling failed", {eventId: event.id, type: event.type});
      res.status(500).send("Handler error");
    }
  }
);
