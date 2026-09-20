import {logger} from "firebase-functions";
import Stripe from "stripe";
import {db} from "../core";

function isMissingStripeResource(error: unknown): boolean {
  if (typeof error !== "object" || error === null) {
    return false;
  }

  const candidate = error as {code?: unknown; statusCode?: unknown};
  return candidate.code === "resource_missing" || candidate.statusCode === 404;
}

/**
 * Returns a Stripe customer that is valid for the currently configured key.
 *
 * Customer ids belong to either Stripe test mode or live mode. A Firestore id
 * saved while the test key was active cannot be retrieved with the live key.
 * Validate the saved id first and replace it when Stripe reports that the
 * resource is missing, which makes test-to-live cutovers safe for existing
 * Firebase users.
 */
export async function getOrCreateStripeCustomer(
  stripe: Stripe,
  uid: string,
  email?: string | null
): Promise<string> {
  const customerRef = db.collection("stripe_customers").doc(uid);
  const customerDoc = await customerRef.get();
  const savedCustomerId = customerDoc.data()?.customerId as string | undefined;

  if (savedCustomerId) {
    try {
      const customer = await stripe.customers.retrieve(savedCustomerId);
      if (!customer.deleted) {
        return customer.id;
      }
      logger.warn("stored Stripe customer was deleted; creating replacement", {
        uid,
        customerId: savedCustomerId,
      });
    } catch (error) {
      if (!isMissingStripeResource(error)) {
        throw error;
      }
      logger.info("stored Stripe customer is not valid for current mode", {
        uid,
        customerId: savedCustomerId,
      });
    }
  }

  const customer = await stripe.customers.create({
    email: email ?? undefined,
    metadata: {firebaseUid: uid},
  });
  await customerRef.set(
    {
      customerId: customer.id,
      email: email ?? null,
      uid,
      stripeLivemode: customer.livemode,
    },
    {merge: true}
  );
  return customer.id;
}
