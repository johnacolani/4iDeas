import {HttpsError, onRequest} from "firebase-functions/v2/https";
import {auth, db, FieldValue} from "../core";
import {normalizeEmail, verifyIcadIdentity} from "./icad-auth";
import {isDevicePlatform} from "./license-policy";
import {
  activateDevice,
  deactivateDevice,
  getOwnerLicense,
} from "./license-store";
import {getNativeStoreOwnerUid} from "./native-store-license";
import {isTestStoreLicenseSource} from "./native-store-source-policy";

const LINK_COLLECTION = "license_account_links";
const REVERSE_LINK_COLLECTION = "license_account_links_by_website";

interface BridgeIdentity {
  icadUid: string;
  ownerUid: string;
  email: string;
  source: "native_store" | "website";
}

/**
 * Resolve the trusted license owner for a signed-in 4iCAD identity.
 *
 * A previously verified native-store purchase takes precedence because it is
 * already bound to the 4iCAD UID. Otherwise we fall back to the existing
 * verified-email bridge into a 4iDeas website account.
 */
async function resolveLinkedIdentity(
  authorizationHeader: string | undefined
): Promise<BridgeIdentity> {
  const icad = await verifyIcadIdentity(authorizationHeader);

  const nativeOwnerUid = await getNativeStoreOwnerUid(icad.uid);
  if (nativeOwnerUid) {
    const nativeLicense = await getOwnerLicense(nativeOwnerUid);
    const isLegacyTestLicense = isTestStoreLicenseSource(
      nativeLicense?.data.source
    );

    // Current sandbox/test purchases never create native-store links. Ignore
    // links left by older deployments so they cannot shadow a verified website
    // or complimentary license. Production native-store licenses still take
    // precedence, including suspended/revoked records.
    if (nativeLicense && !isLegacyTestLicense) {
      return {
        icadUid: icad.uid,
        ownerUid: nativeOwnerUid,
        email: icad.email,
        source: "native_store",
      };
    }
  }

  const linkRef = db.collection(LINK_COLLECTION).doc(icad.uid);
  const existing = await linkRef.get();

  if (existing.exists) {
    const websiteUid = String(existing.data()?.websiteUid ?? "").trim();
    const linkedEmail = normalizeEmail(String(existing.data()?.email ?? ""));
    if (!websiteUid || linkedEmail !== icad.email) {
      throw new HttpsError(
        "permission-denied",
        "The saved 4iCAD license link no longer matches this account."
      );
    }

    try {
      const websiteUser = await auth.getUser(websiteUid);
      const websiteEmail = normalizeEmail(websiteUser.email ?? "");
      if (websiteUser.emailVerified !== true || websiteEmail !== icad.email) {
        throw new HttpsError(
          "permission-denied",
          "The linked 4iDeas account no longer has the same verified email."
        );
      }
    } catch (error: unknown) {
      if (error instanceof HttpsError) throw error;
      throw new HttpsError(
        "permission-denied",
        "The linked 4iDeas account is no longer available."
      );
    }

    return {
      icadUid: icad.uid,
      ownerUid: websiteUid,
      email: icad.email,
      source: "website",
    };
  }

  let websiteUser;
  try {
    websiteUser = await auth.getUserByEmail(icad.email);
  } catch (error: unknown) {
    const code =
      typeof error === "object" && error !== null && "code" in error
        ? String((error as {code?: unknown}).code)
        : "";
    if (code === "auth/user-not-found") {
      throw new HttpsError(
        "not-found",
        "No verified 4iCAD license or matching 4iDeas account was found."
      );
    }
    throw error;
  }

  if (websiteUser.emailVerified !== true) {
    throw new HttpsError(
      "failed-precondition",
      "Verify the email on your 4iDeas account before linking a license."
    );
  }

  const websiteUid = websiteUser.uid;
  const reverseRef = db.collection(REVERSE_LINK_COLLECTION).doc(websiteUid);

  await db.runTransaction(async (tx) => {
    const [linkSnap, reverseSnap] = await Promise.all([
      tx.get(linkRef),
      tx.get(reverseRef),
    ]);

    if (linkSnap.exists) {
      const linkedUid = String(linkSnap.data()?.websiteUid ?? "");
      if (linkedUid !== websiteUid) {
        throw new HttpsError(
          "already-exists",
          "This 4iCAD account is already linked to another 4iDeas account."
        );
      }
      return;
    }

    if (reverseSnap.exists) {
      const linkedIcadUid = String(reverseSnap.data()?.icadUid ?? "");
      if (linkedIcadUid !== icad.uid) {
        throw new HttpsError(
          "already-exists",
          "This 4iDeas account is already linked to another 4iCAD account."
        );
      }
    }

    const common = {
      icadUid: icad.uid,
      websiteUid,
      email: icad.email,
      updatedAt: FieldValue.serverTimestamp(),
    };
    tx.set(linkRef, {
      ...common,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(reverseRef, {
      ...common,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  return {
    icadUid: icad.uid,
    ownerUid: websiteUid,
    email: icad.email,
    source: "website",
  };
}

function serializeLicense(license: NonNullable<Awaited<ReturnType<typeof getOwnerLicense>>>) {
  const data = license.data;
  return {
    id: license.id,
    plan: data.plan,
    primaryPlatform: data.primaryPlatform,
    status: data.status,
    source: data.source,
    primaryDeviceLimit: data.primaryDeviceLimit,
    bonusOtherPlatformLimit: data.bonusOtherPlatformLimit,
    totalDeviceLimit: data.totalDeviceLimit,
    activePrimaryDevices: data.activePrimaryDevices ?? 0,
    activeBonusDevices: data.activeBonusDevices ?? 0,
  };
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
    default:
      return 500;
  }
}

export const fourICadLicenseBridge = onRequest(
  {region: "us-central1"},
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
      const identity = await resolveLinkedIdentity(req.get("authorization"));
      const license = await getOwnerLicense(identity.ownerUid);
      if (!license) {
        throw new HttpsError(
          "not-found",
          "No 4iCAD license was found for this verified account."
        );
      }
      if (license.data.status !== "active") {
        throw new HttpsError(
          "permission-denied",
          "The linked 4iCAD license is not active."
        );
      }

      const action = String(req.body?.action ?? "status").trim().toLowerCase();
      if (action === "status") {
        res.status(200).json({
          linked: true,
          source: identity.source,
          license: serializeLicense(license),
        });
        return;
      }

      const installationId = String(req.body?.installationId ?? "").trim();
      if (!installationId) {
        throw new HttpsError(
          "invalid-argument",
          "installationId is required."
        );
      }

      if (action === "activate") {
        const platform = String(req.body?.platform ?? "").trim().toLowerCase();
        if (!isDevicePlatform(platform)) {
          throw new HttpsError("invalid-argument", "Unsupported platform.");
        }
        const activation = await activateDevice(identity.ownerUid, {
          installationId,
          platform,
          deviceName: req.body?.deviceName
            ? String(req.body.deviceName).trim()
            : null,
          appVersion: req.body?.appVersion
            ? String(req.body.appVersion).trim()
            : null,
        });
        res.status(200).json({
          linked: true,
          source: identity.source,
          license: serializeLicense(license),
          activation,
        });
        return;
      }

      if (action === "deactivate") {
        const result = await deactivateDevice(identity.ownerUid, installationId);
        res.status(200).json({linked: true, source: identity.source, ...result});
        return;
      }

      throw new HttpsError("invalid-argument", "Unsupported bridge action.");
    } catch (error: unknown) {
      const status = statusForError(error);
      const code = error instanceof HttpsError ? error.code : "internal";
      const message =
        error instanceof HttpsError
          ? error.message
          : "The 4iCAD license bridge is temporarily unavailable.";
      res.status(status).json({error: {code, message}});
    }
  }
);
