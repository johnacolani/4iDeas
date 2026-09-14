import {onCall} from "firebase-functions/v2/https";
import type Stripe from "stripe";
import {
  STRIPE_SECRET_KEY,
  requireAuth,
  stripeClient,
} from "../core";
import {getOwnerLicense} from "./license-store";

/**
 * Server-verified status for the license checkout return page.
 *
 * A session id is only a lookup hint. We first trust our own server-written
 * license record; if the Stripe redirect beats the webhook, we ask Stripe
 * directly and return `processing` only when the paid session belongs to the
 * authenticated caller and is a 4iCAD license purchase.
 */
export const getLicensePurchaseStatus = onCall(
  {region: "us-central1", secrets: [STRIPE_SECRET_KEY]},
  async (req) => {
    const {uid} = requireAuth(req);
    const sessionId = req.data?.sessionId
      ? String(req.data.sessionId).trim()
      : null;

    const license = await getOwnerLicense(uid);
    if (
      license?.data.status === "active" &&
      (!sessionId || license.data.orderId === sessionId)
    ) {
      return {
        state: "licensed",
        license: {
          plan: license.data.plan,
          primaryPlatform: license.data.primaryPlatform,
          status: license.data.status,
          primaryDeviceLimit: license.data.primaryDeviceLimit,
          bonusOtherPlatformLimit: license.data.bonusOtherPlatformLimit,
          totalDeviceLimit: license.data.totalDeviceLimit,
        },
      };
    }

    if (!sessionId) {
      return {state: license ? "existing" : "none"};
    }

    let session: Stripe.Checkout.Session;
    try {
      session = await stripeClient().checkout.sessions.retrieve(sessionId);
    } catch {
      return {state: "none"};
    }

    const owner = session.metadata?.firebaseUid ?? session.client_reference_id;
    if (owner !== uid || session.metadata?.purchaseKind !== "4icad_license") {
      return {state: "none"};
    }

    const settled =
      session.payment_status === "paid" ||
      session.payment_status === "no_payment_required";
    if (settled) {
      return {
        state: "processing",
        licensePlan: session.metadata?.licensePlan ?? null,
        primaryPlatform: session.metadata?.primaryPlatform ?? null,
      };
    }

    return {state: "unpaid"};
  }
);
