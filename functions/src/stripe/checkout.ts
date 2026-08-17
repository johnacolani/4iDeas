import {onCall, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {
  COL,
  PRODUCT_KEY,
  SELLABLE_PRODUCT_KEYS,
  SITE_ORIGIN,
  STRIPE_SECRET_KEY,
  db,
  hasEntitlement,
  requireVerifiedAuth,
  stripeClient,
} from "../core";

/**
 * Creates a Stripe Checkout Session for the signed-in caller.
 *
 * The amount is NEVER supplied by the browser. The Price id is read from
 * `product_config/{productKey}`, a collection no client can read or write, and
 * handed to Stripe as the sole line item. The client chooses nothing except
 * whether to start checkout.
 */
export const createCheckoutSession = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    // A purchase requires a verified email address. Enforced here from the
    // verified ID token, not in the UI, so hiding the button is a courtesy
    // rather than the control.
    const {uid, email} = requireVerifiedAuth(req);

    // Only known products can be bought; reject anything else rather than
    // trusting input. A key that is listed but not configured falls through to
    // the "not available yet" branch below, never to a broken checkout.
    const productKey = String(req.data?.productKey ?? PRODUCT_KEY);
    if (!SELLABLE_PRODUCT_KEYS.includes(productKey)) {
      throw new HttpsError("invalid-argument", "Unknown product.");
    }

    if (await hasEntitlement(uid, productKey)) {
      throw new HttpsError("already-exists", "You already own this product.");
    }

    const cfgSnap = await db.collection(COL.productConfig).doc(productKey).get();
    const cfg = cfgSnap.data();
    const priceId = cfg?.stripePriceId as string | undefined;
    if (!cfgSnap.exists || !priceId) {
      logger.error("product_config missing stripePriceId", {productKey});
      throw new HttpsError(
        "failed-precondition",
        "This product is not available for purchase yet."
      );
    }
    if (cfg?.active === false) {
      throw new HttpsError("failed-precondition", "This product is not currently on sale.");
    }

    const stripe = stripeClient();

    // Reuse one Stripe customer per Firebase uid so a buyer's history stays joined up.
    const customerDoc = await db.collection("stripe_customers").doc(uid).get();
    let customerId = customerDoc.data()?.customerId as string | undefined;
    if (!customerId) {
      const customer = await stripe.customers.create({
        email: email ?? undefined,
        metadata: {firebaseUid: uid},
      });
      customerId = customer.id;
      await db.collection("stripe_customers").doc(uid).set(
        {customerId, email: email ?? null, uid},
        {merge: true}
      );
    }

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      customer: customerId,
      line_items: [{price: priceId, quantity: 1}],
      // Stripe renders and validates the promotion-code field itself. No
      // discount arithmetic ever happens in our code or in the browser.
      allow_promotion_codes: true,
      // The product travels in the return URL so the confirmation page checks
      // the entitlement that was actually bought, not always the Windows one.
      success_url:
        `${SITE_ORIGIN}/4icad/success?session_id={CHECKOUT_SESSION_ID}&product=${productKey}`,
      cancel_url: `${SITE_ORIGIN}/4icad?checkout=cancelled`,
      client_reference_id: uid,
      metadata: {firebaseUid: uid, productKey},
      // Mirror metadata onto the PaymentIntent so a paid order is traceable
      // from the Stripe dashboard alone.
      payment_intent_data: {metadata: {firebaseUid: uid, productKey}},
    });

    logger.info("checkout session created", {uid, productKey, sessionId: session.id});
    return {sessionId: session.id, url: session.url};
  }
);
