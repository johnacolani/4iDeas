import {createPrivateKey, sign} from "node:crypto";
import {HttpsError} from "firebase-functions/v2/https";
import {
  APPLE_IAP_ISSUER_ID,
  APPLE_IAP_KEY_ID,
  APPLE_IAP_PRIVATE_KEY,
  APPLE_IAP_SANDBOX_ENABLED,
} from "../core";
import {verifyAndDecodeAppleJws, type AppleJwsObject} from "./apple-jws";

export const APPLE_BUNDLE_IDENTIFIER = "com.johncolani.fouricad";
export const APPLE_FULL_ACCESS_PRODUCT_ID = "com.johncolani.fouricad.fullaccess";

export interface AppleAuthoritativeTransaction {
  transactionId: string;
  originalTransactionId: string;
  productId: string;
  environment: "production" | "sandbox";
  revoked: boolean;
  revocationDate: number | null;
  revocationReason: string | null;
  revocationType: string | null;
  revocationPercentage: number | null;
}

type JsonObject = Record<string, unknown>;

function base64UrlJson(value: JsonObject): string {
  return Buffer.from(JSON.stringify(value), "utf8").toString("base64url");
}

function normalizePrivateKey(value: string): string {
  return value.replace(/\\n/g, "\n").trim();
}

function createAppleApiToken(): string {
  const keyId = APPLE_IAP_KEY_ID.value().trim();
  const issuerId = APPLE_IAP_ISSUER_ID.value().trim();
  const privateKey = normalizePrivateKey(APPLE_IAP_PRIVATE_KEY.value());
  if (!keyId || !issuerId || !privateKey) {
    throw new HttpsError(
      "internal",
      "Apple purchase verification is not configured."
    );
  }

  const now = Math.floor(Date.now() / 1000);
  const header = base64UrlJson({alg: "ES256", kid: keyId, typ: "JWT"});
  const payload = base64UrlJson({
    iss: issuerId,
    iat: now,
    exp: now + 300,
    aud: "appstoreconnect-v1",
    bid: APPLE_BUNDLE_IDENTIFIER,
  });
  const signingInput = `${header}.${payload}`;
  const signature = sign("sha256", Buffer.from(signingInput, "utf8"), {
    key: createPrivateKey(privateKey),
    dsaEncoding: "ieee-p1363",
  }).toString("base64url");
  return `${signingInput}.${signature}`;
}

export function appleSandboxEnabled(): boolean {
  const value = APPLE_IAP_SANDBOX_ENABLED.value().trim().toLowerCase();
  return value === "1" || value === "true" || value === "yes" || value === "on";
}

function normalizedEnvironment(
  value: unknown,
  fallback: "production" | "sandbox"
): "production" | "sandbox" {
  const environment = String(value ?? fallback).trim().toLowerCase();
  if (environment === "sandbox") return "sandbox";
  if (environment === "production") return "production";
  throw new HttpsError("unavailable", "Apple returned an unknown environment.");
}

function numberOrNull(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  return null;
}

function stringOrNull(value: unknown): string | null {
  if (value === undefined || value === null) return null;
  const text = String(value).trim();
  return text || null;
}

function parseTransaction(
  transaction: AppleJwsObject,
  requestedTransactionId: string,
  fallbackEnvironment: "production" | "sandbox"
): AppleAuthoritativeTransaction {
  const bundleId = String(transaction.bundleId ?? "");
  const productId = String(transaction.productId ?? "");
  const transactionId = String(transaction.transactionId ?? "").trim();
  const originalTransactionId = String(
    transaction.originalTransactionId ?? transactionId
  ).trim();
  const environment = normalizedEnvironment(
    transaction.environment,
    fallbackEnvironment
  );

  if (bundleId !== APPLE_BUNDLE_IDENTIFIER) {
    throw new HttpsError(
      "permission-denied",
      "This App Store transaction does not belong to 4iCAD."
    );
  }
  if (productId !== APPLE_FULL_ACCESS_PRODUCT_ID) {
    throw new HttpsError(
      "permission-denied",
      "This App Store transaction is not 4iCAD Full Access."
    );
  }
  if (!transactionId || !originalTransactionId) {
    throw new HttpsError("unavailable", "Apple returned incomplete transaction data.");
  }
  if (
    requestedTransactionId !== transactionId &&
    requestedTransactionId !== originalTransactionId
  ) {
    throw new HttpsError(
      "permission-denied",
      "The App Store transaction id did not match the requested purchase."
    );
  }
  if (environment === "sandbox" && !appleSandboxEnabled()) {
    throw new HttpsError(
      "permission-denied",
      "Sandbox App Store purchases are disabled on this server."
    );
  }

  const revocationDate = numberOrNull(transaction.revocationDate);
  return {
    transactionId,
    originalTransactionId,
    productId,
    environment,
    revoked: revocationDate !== null,
    revocationDate,
    revocationReason: stringOrNull(transaction.revocationReason),
    revocationType: stringOrNull(transaction.revocationType),
    revocationPercentage: numberOrNull(transaction.revocationPercentage),
  };
}

/**
 * Re-query Apple's authoritative transaction endpoint. The returned signed
 * transaction is itself cryptographically verified before any entitlement state
 * is derived from it.
 */
export async function getAppleAuthoritativeTransaction(
  transactionIdValue: string
): Promise<AppleAuthoritativeTransaction> {
  const transactionId = transactionIdValue.trim();
  if (!transactionId) {
    throw new HttpsError(
      "invalid-argument",
      "Apple transaction id is required."
    );
  }

  const bearer = createAppleApiToken();
  const encodedTransactionId = encodeURIComponent(transactionId);
  const allowSandbox = appleSandboxEnabled();
  const environments: Array<{
    name: "production" | "sandbox";
    url: string;
  }> = [
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
    let response: Response;
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
      // Pre-release apps can reject a valid key on the production transaction
      // endpoint while the same key is valid in Sandbox. This fallback exists
      // only while the explicit server-side Sandbox gate is enabled.
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

    let body: JsonObject;
    try {
      const parsed: unknown = JSON.parse(await response.text());
      if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
        throw new Error("invalid");
      }
      body = parsed as JsonObject;
    } catch {
      throw new HttpsError("unavailable", "Apple returned invalid transaction JSON.");
    }

    const signedTransactionInfo = String(body.signedTransactionInfo ?? "").trim();
    if (!signedTransactionInfo) {
      throw new HttpsError("unavailable", "Apple returned no signed transaction.");
    }

    let transaction: AppleJwsObject;
    try {
      transaction = verifyAndDecodeAppleJws(signedTransactionInfo);
    } catch {
      throw new HttpsError(
        "permission-denied",
        "Apple transaction signature verification failed."
      );
    }

    return parseTransaction(transaction, transactionId, environment.name);
  }

  throw new HttpsError(
    "not-found",
    "The App Store could not find this 4iCAD purchase."
  );
}
