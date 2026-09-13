import {X509Certificate, verify as verifySignature} from "node:crypto";

export type AppleJwsObject = Record<string, unknown>;

// Apple publishes these SHA-256 fingerprints for its current public roots.
// Trusting an Apple root is not enough by itself: we also require Apple's
// App Store signed-data leaf/intermediate certificate extensions below.
const APPLE_ROOT_SHA256 = new Set([
  // Apple Inc. Root / Apple Root CA
  "B0B1730ECBC7FF4505142C49F1295E6EDA6BCAED7E2C68C5BE91B5A11001F024",
  // Apple Root CA - G2
  "C2B9B042DD57830E7D117DAC55AC8AE19407D38E41D88F3215BC3A890444A050",
  // Apple Root CA - G3
  "63343ABFB89A6A03EBB57E9B3F5FA7BE7C4F5C756F3017B3A8C488C3653E9179",
]);

// DER encodings of the certificate-extension OIDs used by Apple's official
// App Store Server library when validating signed App Store data.
const APP_STORE_LEAF_OID = Buffer.from("060a2a864886f76364060b01", "hex");
const APP_STORE_INTERMEDIATE_OID = Buffer.from(
  "060a2a864886f76364060201",
  "hex"
);

function parseObject(value: string, label: string): AppleJwsObject {
  let parsed: unknown;
  try {
    parsed = JSON.parse(value);
  } catch {
    throw new Error(`Invalid Apple JWS ${label}.`);
  }
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    throw new Error(`Invalid Apple JWS ${label}.`);
  }
  return parsed as AppleJwsObject;
}

function decodePart(value: string, label: string): AppleJwsObject {
  try {
    return parseObject(Buffer.from(value, "base64url").toString("utf8"), label);
  } catch (error: unknown) {
    if (error instanceof Error && error.message.startsWith("Invalid Apple JWS")) {
      throw error;
    }
    throw new Error(`Invalid Apple JWS ${label}.`);
  }
}

function certificateIsCurrent(cert: X509Certificate): boolean {
  const from = Date.parse(cert.validFrom);
  const to = Date.parse(cert.validTo);
  const now = Date.now();
  return Number.isFinite(from) && Number.isFinite(to) && now >= from && now <= to;
}

function normalizedFingerprint(cert: X509Certificate): string {
  return cert.fingerprint256.replace(/:/g, "").toUpperCase();
}

function hasExtensionOid(cert: X509Certificate, oid: Buffer): boolean {
  return cert.raw.includes(oid);
}

/**
 * Cryptographically verify an Apple App Store JWS using the x5c chain Apple
 * embeds in the header. The chain must terminate at a pinned Apple public root,
 * carry Apple's App Store signed-data certificate extensions, be time-valid,
 * and verify the ES256 JWS signature with the leaf public key.
 *
 * This deliberately does not perform OCSP network checks. Entitlement-changing
 * notification handling still re-queries the authenticated App Store Server API
 * before mutating a license, so the notification is never the sole authority.
 */
export function verifyAndDecodeAppleJws(jws: string): AppleJwsObject {
  const parts = jws.split(".");
  if (parts.length !== 3 || !parts[0] || !parts[1] || !parts[2]) {
    throw new Error("Malformed Apple JWS.");
  }

  const header = decodePart(parts[0], "header");
  if (String(header.alg ?? "") !== "ES256") {
    throw new Error("Unexpected Apple JWS algorithm.");
  }

  const x5c = header.x5c;
  if (!Array.isArray(x5c) || x5c.length !== 3 || x5c.some((v) => typeof v !== "string")) {
    throw new Error("Invalid Apple JWS certificate chain.");
  }

  let leaf: X509Certificate;
  let intermediate: X509Certificate;
  let root: X509Certificate;
  try {
    leaf = new X509Certificate(Buffer.from(x5c[0] as string, "base64"));
    intermediate = new X509Certificate(Buffer.from(x5c[1] as string, "base64"));
    root = new X509Certificate(Buffer.from(x5c[2] as string, "base64"));
  } catch {
    throw new Error("Invalid Apple JWS certificate chain.");
  }

  if (
    !certificateIsCurrent(leaf) ||
    !certificateIsCurrent(intermediate) ||
    !certificateIsCurrent(root)
  ) {
    throw new Error("Apple JWS certificate is outside its validity period.");
  }

  if (!APPLE_ROOT_SHA256.has(normalizedFingerprint(root))) {
    throw new Error("Apple JWS chain does not terminate at a trusted Apple root.");
  }
  if (!root.ca || !root.verify(root.publicKey)) {
    throw new Error("Invalid Apple root certificate.");
  }
  if (
    !intermediate.ca ||
    intermediate.issuer !== root.subject ||
    !intermediate.verify(root.publicKey)
  ) {
    throw new Error("Invalid Apple JWS intermediate certificate.");
  }
  if (leaf.issuer !== intermediate.subject || !leaf.verify(intermediate.publicKey)) {
    throw new Error("Invalid Apple JWS leaf certificate.");
  }
  if (!hasExtensionOid(leaf, APP_STORE_LEAF_OID)) {
    throw new Error("Apple JWS leaf certificate is not for App Store signed data.");
  }
  if (!hasExtensionOid(intermediate, APP_STORE_INTERMEDIATE_OID)) {
    throw new Error("Apple JWS intermediate is not an App Store signing CA.");
  }

  const signature = Buffer.from(parts[2], "base64url");
  if (signature.length !== 64) {
    throw new Error("Invalid Apple JWS signature length.");
  }
  const signingInput = Buffer.from(`${parts[0]}.${parts[1]}`, "utf8");
  const validSignature = verifySignature(
    "sha256",
    signingInput,
    {key: leaf.publicKey, dsaEncoding: "ieee-p1363"},
    signature
  );
  if (!validSignature) {
    throw new Error("Apple JWS signature verification failed.");
  }

  return decodePart(parts[1], "payload");
}
