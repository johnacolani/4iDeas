import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";
import {getStorage} from "firebase-admin/storage";
import {getAuth} from "firebase-admin/auth";
import {defineSecret} from "firebase-functions/params";
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";
import Stripe from "stripe";

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
 */
export const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY");
export const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET");

/** The one product this version sells. */
export const PRODUCT_KEY = "4icad_windows";

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
} as const;

/** Storage prefix for private release binaries. Never publicly readable. */
export const RELEASE_PREFIX = "releases/windows";

/**
 * Legacy admin allowlist, retained ONLY so the custom-claim migration cannot
 * lock the existing administrator out. Once every admin has the `admin: true`
 * claim and it is verified, this list and its uses can be deleted.
 */
export const LEGACY_ADMIN_EMAILS = ["john.ace.colani@outlook.com"];

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

/** Require a signed-in caller. */
export function requireAuth(req: CallableRequest): {uid: string; email: string | null} {
  if (!req.auth?.uid) {
    throw new HttpsError("unauthenticated", "Sign in to continue.");
  }
  const email = (req.auth.token.email as string | undefined) ?? null;
  return {uid: req.auth.uid, email};
}

/**
 * Require a verified admin. Accepts the `admin: true` custom claim, and — only
 * during the claim migration — the legacy email allowlist. Both are read from
 * the verified Firebase ID token, never from anything the browser sends.
 */
export function requireAdmin(req: CallableRequest): {uid: string; email: string | null} {
  const {uid, email} = requireAuth(req);
  const hasClaim = req.auth?.token.admin === true;
  const legacy = !!email && LEGACY_ADMIN_EMAILS.includes(email.toLowerCase().trim());
  if (!hasClaim && !legacy) {
    throw new HttpsError("permission-denied", "Administrator access required.");
  }
  return {uid, email};
}

/** True when the caller currently holds an active entitlement. */
export async function hasEntitlement(uid: string, productKey: string): Promise<boolean> {
  const snap = await db.collection(COL.entitlements).doc(entitlementId(uid, productKey)).get();
  return snap.exists && snap.data()?.active === true;
}
