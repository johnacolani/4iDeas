import {createPrivateKey, sign} from "node:crypto";
import {HttpsError, onRequest} from "firebase-functions/v2/https";
import {
  APPLE_IAP_ISSUER_ID,
  APPLE_IAP_KEY_ID,
  APPLE_IAP_PRIVATE_KEY,
  APPLE_IAP_SANDBOX_ENABLED,
  GOOGLE_PLAY_SERVICE_ACCOUNT_JSON,
} from "../core";
import {verifyIcadIdentity} from "./icad-auth";
import {activateDevice} from "./license-store";
import {
  grantNativeStoreLicense,
  type VerifiedNativePurchase,
} from "./native-store-license";
import type {DevicePlatform} from "./license-policy";

const FULL_ACCESS_PRODUCT_ID = "com.johncolani.fouricad.fullaccess";
const APPLE_BUNDLE_ID = "com.johncolani.fouricad";
const GOOGLE_PACKAGE_NAME = "com.johncolani.fouricad";
const ANDROID_PUBLISHER_SCOPE =
  "https://www.googleapis.com/auth/androidpublisher";

type NativePurchasePlatform = "android" | "ios" | "macos";

type JsonObject = Record<string, unknown>;

interface GoogleServiceAccount {
  client_email: string;
  private_key: string;
  token_uri?: string;
}

function base64UrlJson(value: JsonObject): string {
  return Buffer.from(JSON.stringify(value), "utf8").toString("base64url");
}

function normalizePrivateKey(value: string): string {
  return value.replace(/\\n/g, "\n").trim();
}

function parseJsonObject(value: string): JsonObject {
  try {
    const parsed: unknown = JSON.parse(value);
    if (typeof parsed === "object" && parsed !== null && !Array.isArray(parsed)) {
      return parsed as JsonObject;
    }
  } catch {
    // The caller receives a controlled server error below.
  }
  throw new HttpsError("internal", "Store verification returned invalid JSON.");
}

function parsePlatform(value: unknown): NativePurchasePlatform {
  const platform = String(value ?? "").trim().toLowerCase();
  if (platform === "android" || platform === "ios" || platform === "macos") {
    return platform;
  }
  throw new HttpsError("invalid-argument", "Unsupported native store platform.");
}

function statusForError(error: unknown): number {
  if (!(error instanceof HttpsError)) return 500;
  switch (error.code) {
    case "unauthenticated":
      return 401;
    case "permission-denied":
      return 403;
    case "not-found":
      return 404;
    case "already-exists":
    case "failed-precondition":
      return 409;
    case "resource-exhausted":
      return 429;
    case "invalid-argument":
      return 400;
    case "unavailable":
      return 503;
    default:
      return 500;
  }
}

function createAppleApiToken(): string {
  const keyId = APPLE_IAP_KEY_ID.value().trim();
  const issuerId = APPLE_IAP_ISSUER_ID.value().trim();
  const privateKey = normalizePrivateKey(APPLE_IAP_PRIVATE_KEY.value());
  if (!keyId || !issuerId || !privateKey) {
    throw new HttpsError("internal", "Apple purchase verification is not configured.");
  }

  const now = Math.floor(Date.now() / 1000);
  const header = base64UrlJson({alg: "ES256", kid: keyId, typ: "JWT"});
  const payload = base64UrlJson({
    iss: issuerId,
    iat: now,
    exp: now + 300,
    aud: "appstoreconnect-v1",
    bid: APPLE_BUNDLE_ID,
  });
  const signingInput = `${header}.${payload}`;
  const signature = sign("sha256", Buffer.from(signingInput, "utf8"), {
    key: createPrivateKey(privateKey),
    dsaEncoding: "ieee-p1363",
  }).toString("base64url");
  return `${signingInput}.${signature}`;
}

function appleSandboxEnabled(): boolean {
  const value = APPLE_IAP_SANDBOX_ENABLED.value().trim().toLowerCase();
  return value === "1" || value === "true" || value === "yes" || value === "on";
}

function decodeAppleSignedTransaction(jws: string): JsonObject {
  const parts = jws.split(".");
  if (parts.length !== 3 || !parts[1]) {
    throw new HttpsError("unavailable", "Apple returned malformed transaction data.");
  }
  const payload = Buffer.from(parts[1], "base64url").toString("utf8");
  return parseJsonObject(payload);
}

async function verifyApplePurchase(
  transactionId: string,
  platform: "ios" | "macos"
): Promise<VerifiedNativePurchase> {
  if (!transactionId) {
    throw new HttpsError(
      "invalid-argument",
      "Apple transaction id is required for server verification."
    );
  }

  const bearer = createAppleApiToken();
  const encodedTransactionId = encodeURIComponent(transactionId);
  const allowSandbox = appleSandboxEnabled();
  const environments: Array<{name: "production" | "sandbox"; url: string}> = [
    {
      name: "production",
      url: `https://api.storekit.apple.com/inApps/v1/transactions/${encodedTransactionId}`,
    },
  ];
  if (allowSandbox) {
    environments.push({
      name: "sandbox",
      url: `https://api.storekit-sandbox.apple.com/inApps/v1/transactions/${encodedTransactionId}`,
    });
  }

  for (const environment of environments) {
    let response;
    try {
      response = await fetch(environment.url, {
        method: "GET",
        headers: {Authorization: `Bearer ${bearer}`},
      });
    } catch {
      throw new HttpsError("unavailable", "Could not reach the App Store server.");
    }

    if (response.status === 404) continue;
    if (
      environment.name === "production" &&
      allowSandbox &&
      response.status === 401
    ) {
      // Before an app is live, Apple's production transaction endpoint can
      // reject the same valid API key that works in Sandbox. Only fall back
      // when the server-side test gate is explicitly enabled.
      continue;
    }
    if (!response.ok) {
      throw new HttpsError(
        response.status === 401 ? "failed-precondition" : "unavailable",
        response.status === 401
          ? "Apple purchase verification credentials were rejected."
          : "The App Store could not verify this purchase right now."
      );
    }

    const body = parseJsonObject(await response.text());
    const signedTransactionInfo = String(body.signedTransactionInfo ?? "").trim();
    if (!signedTransactionInfo) {
      throw new HttpsError("unavailable", "Apple returned no signed transaction.");
    }

    // The signed transaction was obtained directly from Apple's authenticated
    // App Store Server API over TLS. We still validate all entitlement-critical
    // fields before granting access.
    const transaction = decodeAppleSignedTransaction(signedTransactionInfo);
    const bundleId = String(transaction.bundleId ?? "");
    const productId = String(transaction.productId ?? "");
    const verifiedTransactionId = String(transaction.transactionId ?? "");
    const originalTransactionId = String(
      transaction.originalTransactionId ?? verifiedTransactionId
    );
    const verifiedEnvironment = String(
      transaction.environment ?? environment.name
    ).toLowerCase();

    if (bundleId !== APPLE_BUNDLE_ID || productId !== FULL_ACCESS_PRODUCT_ID) {
      throw new HttpsError(
        "permission-denied",
        "This App Store transaction does not belong to 4iCAD Full Access."
      );
    }
    if (
      transactionId !== verifiedTransactionId &&
      transactionId !== originalTransactionId
    ) {
      throw new HttpsError(
        "permission-denied",
        "The App Store transaction id did not match the submitted purchase."
      );
    }
    if (transaction.revocationDate !== undefined && transaction.revocationDate !== null) {
      throw new HttpsError(
        "permission-denied",
        "This App Store purchase has been revoked or refunded."
      );
    }
    if (verifiedEnvironment === "sandbox" && !allowSandbox) {
      throw new HttpsError(
        "permission-denied",
        "Sandbox App Store purchases are disabled on this server."
      );
    }

    return {
      store: "apple",
      externalPurchaseId: originalTransactionId || verifiedTransactionId,
      productId,
      platform,
      environment: verifiedEnvironment,
      orderId: verifiedTransactionId || transactionId,
    };
  }

  throw new HttpsError(
    "not-found",
    "The App Store could not find this 4iCAD purchase."
  );
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
  return {
    client_email: clientEmail,
    private_key: privateKey,
    token_uri: tokenUri,
  };
}

async function googlePlayAccessToken(): Promise<string> {
  const serviceAccount = parseGoogleServiceAccount();
  const now = Math.floor(Date.now() / 1000);
  const header = base64UrlJson({alg: "RS256", typ: "JWT"});
  const payload = base64UrlJson({
    iss: serviceAccount.client_email,
    scope: ANDROID_PUBLISHER_SCOPE,
    aud: serviceAccount.token_uri ?? "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  });
  const signingInput = `${header}.${payload}`;
  const signature = sign(
    "RSA-SHA256",
    Buffer.from(signingInput, "utf8"),
    serviceAccount.private_key
  ).toString("base64url");
  const assertion = `${signingInput}.${signature}`;
  const body =
    "grant_type=" +
    encodeURIComponent("urn:ietf:params:oauth:grant-type:jwt-bearer") +
    "&assertion=" +
    encodeURIComponent(assertion);

  let response;
  try {
    response = await fetch(
      serviceAccount.token_uri ?? "https://oauth2.googleapis.com/token",
      {
        method: "POST",
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body,
      }
    );
  } catch {
    throw new HttpsError("unavailable", "Could not authenticate with Google Play.");
  }

  const json = parseJsonObject(await response.text());
  const accessToken = String(json.access_token ?? "").trim();
  if (!response.ok || !accessToken) {
    throw new HttpsError(
      response.status === 400 || response.status === 401
        ? "failed-precondition"
        : "unavailable",
      "Google Play verification credentials were rejected."
    );
  }
  return accessToken;
}

async function acknowledgeGooglePurchase(
  purchaseToken: string,
  accessToken: string
): Promise<void> {
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/` +
    `${encodeURIComponent(GOOGLE_PACKAGE_NAME)}/purchases/products/` +
    `${encodeURIComponent(FULL_ACCESS_PRODUCT_ID)}/tokens/` +
    `${encodeURIComponent(purchaseToken)}:acknowledge`;

  let response;
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

async function verifyGooglePlayPurchase(
  purchaseToken: string
): Promise<VerifiedNativePurchase> {
  if (!purchaseToken) {
    throw new HttpsError(
      "invalid-argument",
      "Google Play purchase token is required for server verification."
    );
  }

  const accessToken = await googlePlayAccessToken();
  const url =
    `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/` +
    `${encodeURIComponent(GOOGLE_PACKAGE_NAME)}/purchases/productsv2/tokens/` +
    encodeURIComponent(purchaseToken);

  let response;
  try {
    response = await fetch(url, {
      method: "GET",
      headers: {Authorization: `Bearer ${accessToken}`},
    });
  } catch {
    throw new HttpsError("unavailable", "Could not reach Google Play.");
  }

  if (!response.ok) {
    throw new HttpsError(
      response.status === 404 ? "not-found" : "unavailable",
      response.status === 404
        ? "Google Play could not find this 4iCAD purchase."
        : "Google Play could not verify this purchase right now."
    );
  }

  const purchase = parseJsonObject(await response.text());
  const purchaseStateContext = purchase.purchaseStateContext;
  const state =
    typeof purchaseStateContext === "object" && purchaseStateContext !== null
      ? String((purchaseStateContext as JsonObject).purchaseState ?? "")
      : "";
  if (state !== "PURCHASED") {
    throw new HttpsError(
      "failed-precondition",
      state === "PENDING"
        ? "This Google Play purchase is still pending."
        : "This Google Play purchase is not active."
    );
  }

  const lineItems = Array.isArray(purchase.productLineItem)
    ? purchase.productLineItem
    : [];
  const hasFullAccess = lineItems.some((item) => {
    if (typeof item !== "object" || item === null) return false;
    return String((item as JsonObject).productId ?? "") === FULL_ACCESS_PRODUCT_ID;
  });
  if (!hasFullAccess) {
    throw new HttpsError(
      "permission-denied",
      "This Google Play purchase is not for 4iCAD Full Access."
    );
  }

  const acknowledgementState = String(purchase.acknowledgementState ?? "");
  if (acknowledgementState !== "ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED") {
    await acknowledgeGooglePurchase(purchaseToken, accessToken);
  }

  const testPurchaseContext = purchase.testPurchaseContext;
  const isTestPurchase =
    typeof testPurchaseContext === "object" &&
    testPurchaseContext !== null &&
    String((testPurchaseContext as JsonObject).fopType ?? "") === "TEST";

  return {
    store: "google_play",
    externalPurchaseId: purchaseToken,
    productId: FULL_ACCESS_PRODUCT_ID,
    platform: "android",
    environment: isTestPurchase ? "test" : "production",
    orderId: String(purchase.orderId ?? "").trim() || null,
  };
}

function serializeLicense(license: {
  id: string;
  data: {
    plan: string;
    primaryPlatform: string;
    status: string;
    primaryDeviceLimit: number;
    bonusOtherPlatformLimit: number;
    totalDeviceLimit: number;
    activePrimaryDevices: number;
    activeBonusDevices: number;
  };
}) {
  return {
    id: license.id,
    plan: license.data.plan,
    primaryPlatform: license.data.primaryPlatform,
    status: license.data.status,
    primaryDeviceLimit: license.data.primaryDeviceLimit,
    bonusOtherPlatformLimit: license.data.bonusOtherPlatformLimit,
    totalDeviceLimit: license.data.totalDeviceLimit,
    activePrimaryDevices: license.data.activePrimaryDevices ?? 0,
    activeBonusDevices: license.data.activeBonusDevices ?? 0,
  };
}

/**
 * Verify a native one-time Full Access purchase against the authoritative store
 * API, persist replay-resistant evidence, grant the trusted license, and
 * activate the current installation under the existing seat policy.
 */
export const fourICadVerifyNativePurchase = onRequest(
  {
    region: "us-central1",
    secrets: [
      APPLE_IAP_KEY_ID,
      APPLE_IAP_ISSUER_ID,
      APPLE_IAP_PRIVATE_KEY,
      APPLE_IAP_SANDBOX_ENABLED,
      GOOGLE_PLAY_SERVICE_ACCOUNT_JSON,
    ],
  },
  async (req, res) => {
    res.set("Access-Control-Allow-Origin", "*");
    res.set("Access-Control-Allow-Headers", "Authorization, Content-Type");
    res.set("Access-Control-Allow-Methods", "POST, OPTIONS");
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }
    if (req.method !== "POST") {
      res.status(405).json({error: {code: "method-not-allowed"}});
      return;
    }

    try {
      const identity = await verifyIcadIdentity(req.get("authorization"));
      const platform = parsePlatform(req.body?.platform);
      const productId = String(req.body?.productId ?? "").trim();
      if (productId !== FULL_ACCESS_PRODUCT_ID) {
        throw new HttpsError(
          "invalid-argument",
          "Unsupported 4iCAD store product."
        );
      }

      const installationId = String(req.body?.installationId ?? "").trim();
      if (!installationId) {
        throw new HttpsError("invalid-argument", "installationId is required.");
      }

      let verifiedPurchase: VerifiedNativePurchase;
      if (platform === "android") {
        verifiedPurchase = await verifyGooglePlayPurchase(
          String(req.body?.verificationData ?? "").trim()
        );
      } else {
        verifiedPurchase = await verifyApplePurchase(
          String(req.body?.transactionId ?? "").trim(),
          platform
        );
      }

      const grant = await grantNativeStoreLicense({
        icadUid: identity.uid,
        email: identity.email,
        purchase: verifiedPurchase,
      });
      const activation = await activateDevice(grant.ownerUid, {
        installationId,
        platform: verifiedPurchase.platform as DevicePlatform,
        appVersion: req.body?.appVersion
          ? String(req.body.appVersion).trim()
          : null,
      });

      res.status(200).json({
        verified: true,
        store: verifiedPurchase.store,
        environment: verifiedPurchase.environment,
        license: serializeLicense(grant.license),
        activation,
      });
    } catch (error: unknown) {
      const status = statusForError(error);
      const code = error instanceof HttpsError ? error.code : "internal";
      const message =
        error instanceof HttpsError
          ? error.message
          : "Native store purchase verification is temporarily unavailable.";
      res.status(status).json({error: {code, message}});
    }
  }
);
