import {applicationDefault, getApps, initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {onRequest, HttpsError} from "firebase-functions/v2/https";
import {auth, db, FieldValue} from "../core";
import {isDevicePlatform} from "./license-policy";
import {
  activateDevice,
  deactivateDevice,
  getOwnerLicense,
} from "./license-store";

const ICAD_AUTH_PROJECT_ID = "icad-75d53";
const ICAD_AUTH_APP_NAME = "icad-license-bridge";
const LINK_COLLECTION = "license_account_links";
const REVERSE_LINK_COLLECTION = "license_account_links_by_website";

interface BridgeIdentity {
  icadUid: string;
  websiteUid: string;
  email: string;
}

function normalizeEmail(value: string): string {
  return value.trim().toLowerCase();
}

function icadAuth() {
  const existing = getApps().find((app) => app.name === ICAD_AUTH_APP_NAME);
  const app =
    existing ??
    initializeApp(
      {
        credential: applicationDefault(),
        projectId: ICAD_AUTH_PROJECT_ID,
      },
      ICAD_AUTH_APP_NAME
    );
  return getAuth(app);
}

async function verifyIcadIdentity(
  authorizationHeader: string | undefined
): Promise<{uid: string; email: string}> {
  const match = authorizationHeader?.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    throw new HttpsError("unauthenticated", "4iCAD sign-in is required.");
  }
  // Signature, issuer, audience and expiry are verified against icad-75d53.
  // Revocation lookup is intentionally not requested here because the function
  // runs under the separate 4iDeas project service account; Firebase ID tokens
  // are short-lived and a foreign-project revocation lookup would require
  // cross-project IAM solely for this bridge.
  const decoded = await icadAuth().verifyIdToken(match[1]);
  const email = typeof decoded.email === "string" ? normalizeEmail(decoded.email) : "";
  if (!email || decoded.email_verified !== true) {
    throw new HttpsError(
      "failed-precondition",
      "Verify the email on your 4iCAD account before linking a license."
    );
  }
  return {uid: decoded.uid, email};
}

async function resolveLinkedIdentity(
  authorizationHeader: string | undefined
): Promise<BridgeIdentity> {
  const icad = await verifyIcadIdentity(authorizationHeader);
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

    return {icadUid: icad.uid, websiteUid, email: icad.email};
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
        "No 4iDeas account was found with the same verified email."
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
  const reverseRef = db
    .collection(REVERSE_LINK_COLLECTION)
    .doc(websiteUid);

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

  return {icadUid: icad.uid, websiteUid, email: icad.email};
}

function serializeLicense(license: NonNullable<Awaited<ReturnType<typeof getOwnerLicense>>>) {
  const data = license.data;
  return {
    id: license.id,
    plan: data.plan,
    primaryPlatform: data.primaryPlatform,
    status: data.status,
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
      const license = await getOwnerLicense(identity.websiteUid);
      if (!license) {
        throw new HttpsError(
          "not-found",
          "No 4iCAD license was found on the linked 4iDeas account."
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
        const activation = await activateDevice(identity.websiteUid, {
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
          license: serializeLicense(license),
          activation,
        });
        return;
      }

      if (action === "deactivate") {
        const result = await deactivateDevice(
          identity.websiteUid,
          installationId
        );
        res.status(200).json({linked: true, ...result});
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
