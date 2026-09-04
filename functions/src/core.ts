import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {getAuth} from "firebase-admin/auth";
import {defineSecret} from "firebase-functions/params";
import Stripe from "stripe";

export {
  DOWNLOADABLE_PRODUCTS,
  LINUX_PRODUCT_KEY,
  PRODUCT_KEY,
  RELEASE_PREFIX,
  SELLABLE_PRODUCT_KEYS,
  WEB_PRODUCT_KEY,
} from "./product-catalog";
export type {DownloadPlatform, DownloadableProduct} from "./product-catalog";

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

/** Public site origin used to build Stripe return URLs. */
export const SITE_ORIGIN = "https://4ideasapp.com";

/** Firestore collections. `orders` is deliberately NOT reused — it holds client
 *  project inquiries with an entirely different shape. */
export const COL = {
  products: "products",
  productConfig: "product_config",
  licensePlanConfig: "license_plan_config",
  releases: "releases",
  productOrders: "product_orders",
  entitlements: "entitlements",
  stripeEvents: "stripe_events",
  webTrials: "web_trials",
  licenses: "licenses",
  licenseDevices: "license_devices",
  licenseAudit: "license_audit",
} as const;

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
