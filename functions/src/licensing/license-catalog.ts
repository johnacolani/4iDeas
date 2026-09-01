import {onCall} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {
  COL,
  STRIPE_SECRET_KEY,
  db,
  stripeClient,
} from "../core";
import {LICENSE_PLAN_POLICIES, type LicensePlan} from "./license-policy";

const PLAN_ORDER: LicensePlan[] = ["individual", "company"];

/**
 * Public-safe license catalog for the 4iCAD pricing page.
 *
 * Stripe Price ids stay in a server-only collection and are never returned.
 * The callable asks Stripe for the current amount/currency, so the number shown
 * on the page cannot silently drift from the amount Checkout will charge.
 */
export const getLicensePlans = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async () => {
    const stripe = stripeClient();
    const plans = await Promise.all(
      PLAN_ORDER.map(async (plan) => {
        const configSnap = await db.collection(COL.licensePlanConfig).doc(plan).get();
        const config = configSnap.data();
        const policy = LICENSE_PLAN_POLICIES[plan];
        const priceId = config?.stripePriceId as string | undefined;
        const active = configSnap.exists && config?.active !== false && !!priceId;

        let amountMinor: number | null = null;
        let currency: string | null = null;
        if (active && priceId) {
          try {
            const price = await stripe.prices.retrieve(priceId);
            if (price.active && price.type === "one_time") {
              amountMinor = price.unit_amount;
              currency = price.currency;
            } else {
              logger.warn("license plan Stripe price is not an active one-time price", {
                plan,
              });
            }
          } catch {
            logger.error("could not retrieve license plan Stripe price", {plan});
          }
        }

        return {
          plan,
          displayName: plan === "company" ? "Company" : "Individual",
          active: active && amountMinor != null && currency != null,
          amountMinor,
          currency,
          primaryDeviceLimit: policy.primaryDeviceLimit,
          bonusOtherPlatformLimit: policy.bonusOtherPlatformLimit,
          totalDeviceLimit: policy.totalDeviceLimit,
        };
      })
    );

    return {plans};
  }
);
