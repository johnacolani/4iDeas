import {applicationDefault, getApps, initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {HttpsError} from "firebase-functions/v2/https";

const ICAD_AUTH_PROJECT_ID = "icad-75d53";
const ICAD_AUTH_APP_NAME = "icad-license-bridge";

export interface IcadIdentity {
  uid: string;
  email: string;
}

export function normalizeEmail(value: string): string {
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

/**
 * Verify a short-lived Firebase ID token issued by the separate 4iCAD project.
 * The caller's UID/email are derived only from the signed token, never from the
 * JSON body. Verified email is required before money/access can be linked.
 */
export async function verifyIcadIdentity(
  authorizationHeader: string | undefined
): Promise<IcadIdentity> {
  const match = authorizationHeader?.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    throw new HttpsError("unauthenticated", "4iCAD sign-in is required.");
  }

  const decoded = await icadAuth().verifyIdToken(match[1]);
  const email =
    typeof decoded.email === "string" ? normalizeEmail(decoded.email) : "";
  if (!email || decoded.email_verified !== true) {
    throw new HttpsError(
      "failed-precondition",
      "Verify the email on your 4iCAD account before linking a license."
    );
  }

  return {uid: decoded.uid, email};
}
