import {onCall, HttpsError} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {
  COL,
  SITE_ORIGIN,
  STRIPE_SECRET_KEY,
  db,
  requireVerifiedAuth,
  stripeClient,
} from "../core";
import {
  isDevicePlatform,
  isLicensePlan,
  type DevicePlatform,
  type LicensePlan,
} from "./license-policy";
import {getOwnerLicense} from "./license-store";

/**
 * Starts checkout for the new device-based license model.
 *
 * The browser supplies only the requested plan and primary platform. The Stripe
 * Price id remains private in `license_plan_config/{plan}` and is never accepted
 * from client input.
 */
export const createLicenseCheckoutSession = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    const {uid, email} = requireVerifiedAuth(req);
    const rawPlan = String(req.data?.plan ?? "").trim().toLowerCase();
    const rawPlatform = String(req.data?.primaryPlatform ?? "")
      .trim()
      .toLowerCase();

    if (!isLicensePlan(rawPlan)) {
      throw new HttpsError("invalid-argument", "Unknown license plan.");
    }
    if (!isDevicePlatform(rawPlatform)) {
      throw new HttpsError("invalid-argument", "Unsupported primary platform.");
    }

    const plan: LicensePlan = rawPlan;
    const primaryPlatform: DevicePlatform = rawPlatform;
    const existing = await getOwnerLicense(uid);
    if (existing?.data.status === "active") {
      if (existing.data.primaryPlatform !== primaryPlatform) {
        throw new HttpsError(
          "failed-precondition",
          "Deactivate or migrate the current primary platform before changing it."
        );
      }
      if (existing.data.plan === plan || existing.data.plan === "company") {
        throw new HttpsError("already-exists", "You already have this license.");
      }
      // The only supported in-place purchase transition for phase one is an
      // Individual -> Company upgrade on the same primary platform.
      if (!(existing.data.plan === "individual" && plan === "company")) {
        throw new HttpsError("failed-precondition", "Unsupported license change.");
      }
    }

    const cfgSnap = await db.collection(COL.licensePlanConfig).doc(plan).get();
    const cfg = cfgSnap.data();
    const priceId = cfg?.stripePriceId as string | undefined;
    if (!cfgSnap.exists || !priceId) {
      logger.error("license plan config missing stripePriceId", {plan});
      throw new HttpsError(
        "failed-precondition",
        "This license plan is not available for purchase yet."
      );
    }
    if (cfg?.active === false) {
      throw new HttpsError(
        "failed-precondition",
        "This license plan is not currently on sale."
      );
    }

    const stripe = stripeClient();
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

    const metadata = {
      firebaseUid: uid,
      purchaseKind: "4icad_license",
      licensePlan: plan,
      primaryPlatform,
    };

    const session = await stripe.checkout.sessions.create({
      mode: "payment",
      customer: customerId,
      line_items: [{price: priceId, quantity: 1}],
      allow_promotion_codes: true,
      success_url:
        `${SITE_ORIGIN}/4icad/license-success?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${SITE_ORIGIN}/4icad?checkout=cancelled`,
      client_reference_id: uid,
      metadata,
      payment_intent_data: {metadata},
    });

    logger.info("license checkout session created", {
      uid,
      plan,
      primaryPlatform,
      sessionId: session.id,
    });

    return {sessionId: session.id, url: session.url};
  }
);
