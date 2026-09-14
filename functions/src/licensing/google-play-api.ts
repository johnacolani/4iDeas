import {sign} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {GOOGLE_PLAY_SERVICE_ACCOUNT_JSON} from "../core";
import {
  GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID,
  GOOGLE_PLAY_PACKAGE_NAME,
  authoritativeGooglePurchaseActive,
} from "./google-play-notification-policy";

const ANDROID_PUBLISHER_SCOPE =
  "https://www.googleapis.com/auth/androidpublisher";

type JsonObject = Record<string, unknown>;

interface GoogleServiceAccount {
  clientEmail: string;
  privateKey: string;
  tokenUri: string;
}

export interface GooglePlayAuthoritativePurchase {
  productId: string;
  purchaseState: string;
  active: boolean;
  environment: "test" | "production";
  orderId: string | null;
  acknowledgementState: string;
  quantity: number | null;
  refundableQuantity: number | null;
}

function objectOrNull(value: unknown): JsonObject | null {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? (value as JsonObject)
    : null;
}

function parseJsonObject(value: string): JsonObject {
  try {
    const parsed: unknown = JSON.parse(value);
    const object = objectOrNull(parsed);
    if (object) return object;
  } catch {
    // Controlled error below.
  }
  throw new HttpsError("unavailable", "Google Play returned invalid JSON.");
}

function normalizePrivateKey(value: string): string {
  return value.replace(/\\n/g, "\n").trim();
}

function base64UrlJson(value: JsonObject): string {
  return Buffer.from(JSON.stringify(value), "utf8").toString("base64url");
}

function nullableNumber(value: unknown): number | null {
  if (value === null || value === undefined || value === "") return null;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function parseGoogleServiceAccount(): GoogleServiceAccount {
  const parsed = parseJsonObject(GOOGLE_PLAY_SERVICE_ACCOUNT_JSON.value());
  const clientEmail = String(parsed.client_email ?? "").trim();
  const privateKey = normalizePrivateKey(String(parsed.private_key ?? ""));
  const tokenUri = String(
    parsed.token_uri ?? "https://oauth2.googleapis.com/token"
  ).trim();
  if (!clientEmail || !privateKey || !tokenUri) {
    throw new HttpsError(
      "internal",
      "Google Play purchase verification is not configured."
    );
  }
  return {clientEmail, privateKey, tokenUri};
}

async function googlePlayAccessToken(): Promise<string> {
  const serviceAccount = parseGoogleServiceAccount();
  const now = Math.floor(Date.now() / 1000);
  const header = base64UrlJson({alg: "RS256", typ: "JWT"});
  const payload = base64UrlJson({
    iss: serviceAccount.clientEmail,
    scope: ANDROID_PUBLISHER_SCOPE,
    aud: serviceAccount.tokenUri,
    iat: now,
    exp: now + 3600,
  });
  const signingInput = `${header}.${payload}`;
  const signature = sign(
    "RSA-SHA256",
    Buffer.from(signingInput, "utf8"),
    serviceAccount.privateKey
  ).toString("base64url");
  const assertion = `${signingInput}.${signature}`;

  let response: Response;
  try {
    response = await fetch(serviceAccount.tokenUri, {
      method: "POST",
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body:
        "grant_type=" +
        encodeURIComponent("urn:ietf:params:oauth:grant-type:jwt-bearer") +
        "&assertion=" +
        encodeURIComponent(assertion),
    });
  } catch {
    throw new HttpsError("unavailable", "Could not authenticate with Google Play.");
  }

  const body = parseJsonObject(await response.text());
  const accessToken = String(body.access_token ?? "").trim();
  if (!response.ok || !accessToken) {
    throw new HttpsError(
      response.status === 400 || response.status === 401 || response.status === 403
        ? "failed-precondition"
        : "unavailable",
      "Google Play verification credentials were rejected."
    );
  }
  return accessToken;
}

function fullAccessLineItem(purchase: JsonObject): JsonObject {
  const items = Array.isArray(purchase.productLineItem)
    ? purchase.productLineItem
    : [];
  for (const item of items) {
    const object = objectOrNull(item);
    if (
      object &&
      String(object.productId ?? "").trim() === GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID
    ) {
      return object;
    }
  }
  throw new HttpsError(
    "permission-denied",
    "This Google Play purchase is not for 4iCAD Full Access."
  );
}

async function acknowledgeGooglePurchase(
  purchaseToken: string,
  accessToken: string
): Promise<void> {
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/` +
    `${encodeURIComponent(GOOGLE_PLAY_PACKAGE_NAME)}/purchases/products/` +
    `${encodeURIComponent(GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID)}/tokens/` +
    `${encodeURIComponent(purchaseToken)}:acknowledge`;

  let response: Response;
  try {
    response = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: "{}",
    });
  } catch {
    throw new HttpsError(
      "unavailable",
      "Google Play purchase acknowledgement could not be completed."
    );
  }

  if (!response.ok) {
    throw new HttpsError(
      "unavailable",
      "Google Play purchase acknowledgement could not be completed."
    );
  }
}

/**
 * Re-query Google Play for the latest ProductPurchaseV2 state. The RTDN payload
 * is never authoritative; callers use this result before changing entitlement.
 */
export async function getGooglePlayAuthoritativePurchase(
  purchaseToken: string,
  options: {acknowledgeIfNeeded?: boolean} = {}
): Promise<GooglePlayAuthoritativePurchase> {
  if (!purchaseToken.trim()) {
    throw new HttpsError(
      "invalid-argument",
      "Google Play purchase token is required."
    );
  }

  const accessToken = await googlePlayAccessToken();
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/` +
    `${encodeURIComponent(GOOGLE_PLAY_PACKAGE_NAME)}/purchases/productsv2/tokens/` +
    encodeURIComponent(purchaseToken);

  let response: Response;
  try {
    response = await fetch(url, {
      method: "GET",
      headers: {Authorization: `Bearer ${accessToken}`},
    });
  } catch {
    throw new HttpsError("unavailable", "Could not reach Google Play.");
  }

  if (!response.ok) {
    const code = response.status === 404
      ? "not-found"
      : response.status === 401 || response.status === 403
        ? "failed-precondition"
        : "unavailable";
    throw new HttpsError(
      code,
      response.status === 404
        ? "Google Play could not find this 4iCAD purchase."
        : response.status === 401 || response.status === 403
          ? "Google Play purchase verification is not authorized."
          : "Google Play could not verify this purchase right now."
    );
  }

  const purchase = parseJsonObject(await response.text());
  const item = fullAccessLineItem(purchase);
  const details = objectOrNull(item.productOfferDetails);
  const quantity = nullableNumber(details?.quantity);
  const refundableQuantity = nullableNumber(details?.refundableQuantity);
  const stateContext = objectOrNull(purchase.purchaseStateContext);
  const purchaseState = String(stateContext?.purchaseState ?? "").trim();
  const acknowledgementState = String(purchase.acknowledgementState ?? "").trim();
  const testContext = objectOrNull(purchase.testPurchaseContext);
  const environment = String(testContext?.fopType ?? "").trim() === "TEST"
    ? "test" as const
    : "production" as const;

  if (
    options.acknowledgeIfNeeded === true &&
    purchaseState === "PURCHASED" &&
    acknowledgementState !== "ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED"
  ) {
    await acknowledgeGooglePurchase(purchaseToken, accessToken);
  }

  return {
    productId: GOOGLE_PLAY_FULL_ACCESS_PRODUCT_ID,
    purchaseState,
    active: authoritativeGooglePurchaseActive({
      purchaseState,
      refundableQuantity,
    }),
    environment,
    orderId: String(purchase.orderId ?? "").trim() || null,
    acknowledgementState,
    quantity,
    refundableQuantity,
  };
}
