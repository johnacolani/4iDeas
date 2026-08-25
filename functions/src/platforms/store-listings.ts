import {onCall, HttpsError} from "firebase-functions/v2/https";
import {COL, FieldValue, db, requireAdmin} from "../core";

const STORE_PRODUCTS = new Set([
  "4icad_ios",
  "4icad_android",
  "4icad_macos",
]);

function validateStoreUrl(raw: string): string {
  let url: URL;
  try {
    url = new URL(raw);
  } catch (_) {
    throw new HttpsError("invalid-argument", "Enter a valid store URL.");
  }
  if (url.protocol !== "https:") {
    throw new HttpsError("invalid-argument", "The store URL must use https.");
  }
  return url.toString();
}

/** Maintains public Apple/Google links without touching releases or commerce. */
export const setPlatformStoreListing = onCall(
  {region: "us-central1"},
  async (req) => {
    requireAdmin(req);
    const productKey = String(req.data?.productKey ?? "").trim();
    const rawUrl = String(req.data?.storeUrl ?? "").trim();
    const platformNote = String(req.data?.platformNote ?? "").trim();
    const storeVersion = String(req.data?.storeVersion ?? "").trim();

    if (!STORE_PRODUCTS.has(productKey)) {
      throw new HttpsError("invalid-argument", "Unknown store platform.");
    }

    const ref = db.collection(COL.products).doc(productKey);
    if (!rawUrl) {
      await ref.set({
        storeUrl: FieldValue.delete(),
        storeVersion: FieldValue.delete(),
        platformNote: FieldValue.delete(),
        platformStatus: "soon",
        updatedAt: FieldValue.serverTimestamp(),
      }, {merge: true});
      return {ok: true, published: false};
    }

    const storeUrl = validateStoreUrl(rawUrl);
    await ref.set({
      storeUrl,
      platformStatus: "store",
      platformNote: platformNote || FieldValue.delete(),
      storeVersion: storeVersion || FieldValue.delete(),
      updatedAt: FieldValue.serverTimestamp(),
    }, {merge: true});
    return {ok: true, published: true};
  }
);
