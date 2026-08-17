import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {getAuth} from "firebase-admin/auth";
import {defineSecret} from "firebase-functions/params";
import Stripe from "stripe";

// Authorization guards live in their own side-effect-free module so they can be
// unit tested without initialising the Admin SDK. Re-exported here so existing
// call sites keep importing them from `core`.
export {
  LEGACY_ADMIN_EMAILS,
  requireAuth,
  requireVerifiedAuth,
  requireAdmin,
} from "./auth-guards";
export type {Caller} from "./auth-guards";

initializeApp();

export const db = getFirestore();
export const storage = getStorage();
export const auth = getAuth();
export {FieldValue};

/**
 * Secrets live in Google Secret Manager and are injected at runtime. They are
 * never bundled into client code and never logged.
 *
 * Set them with:
 *   firebase functions:secrets:set STRIPE_SECRET_KEY
 *   firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
 *   firebase functions:secrets:set WEB_TRIAL_SIGNING_KEY
 */
export const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");
export const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");

/**
 * HMAC key for 4iCAD web-app trial tokens.
 *
 * Only this backend ever holds it: the web app verifies a token by calling
 * `verifyWebTrial`, never by checking a signature itself. Any long random
 * string works — e.g. `openssl rand -base64 48`.
 */
export const WEB_TRIAL_SIGNING_KEY = defineSecret("WEB_TRIAL_SIGNING_KEY");

/** The Windows desktop build — the product with an installer behind it. */
export const PRODUCT_KEY = "4icad_windows";

/** The browser build, sold separately. */
export const WEB_PRODUCT_KEY = "4icad_web";

/**
 * Product keys checkout will sell.
 *
 * An allowlist rather than "any key with a price", so a typo or a probing
 * client cannot reach a half-configured product. A key listed here still needs
 * its own `product_config/{key}` document with a Stripe Price before it can be
 * bought — the two together are what put a platform on sale.
 */
export const SELLABLE_PRODUCT_KEYS: readonly string[] = [PRODUCT_KEY, WEB_PRODUCT_KEY];

/** Public site origin used to build Stripe return URLs. */
export const SITE_ORIGIN = "https://4ideasapp.com";

/** Firestore collections. `orders` is deliberately NOT reused — it holds client
 *  project inquiries with an entirely different shape. */
export const COL = {
  products: "products",
  productConfig: "product_config",
  releases: "releases",
  productOrders: "product_orders",
  entitlements: "entitlements",
  stripeEvents: "stripe_events",
  webTrials: "web_trials",
} as const;

/** Storage prefix for private release binaries. Never publicly readable. */
export const RELEASE_PREFIX = "releases/windows";

let cachedStripe: Stripe | null = null;

/** Lazily construct Stripe so the secret is only read inside a request. */
export function stripeClient(): Stripe {
  if (!cachedStripe) {
    // Pin to the API version this SDK build targets, so a future SDK bump is a
    // deliberate, reviewable change rather than a silent behaviour shift.
    cachedStripe = new Stripe(STRIPE_SECRET_KEY.value(), {
      apiVersion: "2025-02-24.acacia",
      typescript: true,
    });
  }
  return cachedStripe;
}

/** Deterministic entitlement id so a user can hold a product only once. */
export function entitlementId(uid: string, productKey: string): string {
  return `${uid}__${productKey}`;
}

/** True when the caller currently holds an active entitlement. */
export async function hasEntitlement(uid: string, productKey: string): Promise<boolean> {
  const snap = await db.collection(COL.entitlements).doc(entitlementId(uid, productKey)).get();
  return snap.exists && snap.data()?.active === true;
}
