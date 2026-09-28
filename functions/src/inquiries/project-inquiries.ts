import {createHash} from "node:crypto";
import type {UserRecord} from "firebase-admin/auth";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {
  auth,
  db,
  FieldValue,
  requireAdmin,
  requireVerifiedAuth,
} from "../core";

const PROJECT_INQUIRIES = "project_inquiries";
const PUBLIC_RATE_LIMITS = "_public_rate_limits";

function readText(
  value: unknown,
  field: string,
  maxLength: number,
  required = true
): string {
  if (typeof value !== "string") {
    if (!required && (value == null || value === "")) return "";
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  const trimmed = value.trim();
  if (required && !trimmed) {
    throw new HttpsError("invalid-argument", `${field} is required.`);
  }
  if (trimmed.length > maxLength) {
    throw new HttpsError(
      "invalid-argument",
      `${field} is too long (max ${maxLength} characters).`
    );
  }
  return trimmed;
}

function normalizeEmail(value: unknown): {email: string; emailLower: string} {
  const email = readText(value, "Email", 254);
  const emailLower = email.toLowerCase();
  const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailPattern.test(emailLower)) {
    throw new HttpsError("invalid-argument", "Enter a valid email address.");
  }
  return {email, emailLower};
}

async function enforcePublicRateLimit(ip: string | undefined): Promise<void> {
  if (!ip) return;

  const digest = createHash("sha256").update(ip).digest("hex");
  const ref = db
    .collection(PUBLIC_RATE_LIMITS)
    .doc(`project_inquiry_${digest}`);
  const nowMs = Date.now();
  const cooldownMs = 30_000;

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const last = snap.data()?.lastSubmittedAt;
    const lastMs =
      last && typeof last.toMillis === "function" ? last.toMillis() : 0;

    if (lastMs > 0 && nowMs - lastMs < cooldownMs) {
      throw new HttpsError(
        "resource-exhausted",
        "Please wait a moment before sending another inquiry."
      );
    }

    tx.set(
      ref,
      {
        lastSubmittedAt: FieldValue.serverTimestamp(),
      },
      {merge: true}
    );
  });
}

/**
 * Public lead-capture endpoint.
 *
 * The browser never writes directly to Firestore. This callable validates and
 * rate-limits anonymous submissions, then stores a lead that admins can manage
 * inside 4iDeas.
 */
export const submitProjectInquiry = onCall(async (request) => {
  const data = request.data ?? {};

  // Honeypot used by the Flutter form. Real visitors never fill this field.
  if (typeof data.website === "string" && data.website.trim().isNotEmpty) {
    return {accepted: true};
  }

  const {email, emailLower} = normalizeEmail(data.email);
  const name = readText(data.name, "Name", 120);
  const company = readText(data.company, "Company", 160, false);
  const projectType = readText(data.projectType, "Project type", 120);
  const budgetRange = readText(data.budgetRange, "Budget range", 80);
  const timeline = readText(data.timeline, "Timeline", 80);
  const message = readText(data.message, "Project description", 4000);
  const source = readText(
    data.source ?? "project_inquiry_contact_page",
    "Source",
    120
  );

  const forwardedFor = request.rawRequest.headers["x-forwarded-for"];
  const ipFromHeader = Array.isArray(forwardedFor)
    ? forwardedFor[0]
    : forwardedFor?.split(",")[0]?.trim();
  await enforcePublicRateLimit(request.rawRequest.ip || ipFromHeader);

  const ref = db.collection(PROJECT_INQUIRIES).doc();
  await ref.set({
    name,
    email,
    emailLower,
    company: company || "—",
    projectType,
    budgetRange,
    timeline,
    message,
    source,
    status: "new",
    adminReply: "",
    adminNotes: "",
    clientReply: "",
    userId: null,
    linkedOrderId: null,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  return {
    accepted: true,
    inquiryId: ref.id,
  };
});

/**
 * When a visitor later signs in with the same verified email address, link any
 * earlier anonymous inquiries to that Firebase uid. The Profile screen can then
 * show the inquiry and future admin replies without exposing email-based reads
 * in Firestore rules.
 */
export const claimMyProjectInquiries = onCall(async (request) => {
  const caller = requireVerifiedAuth(request);
  if (!caller.email) {
    throw new HttpsError(
      "failed-precondition",
      "Your account does not have an email address."
    );
  }

  const emailLower = caller.email.toLowerCase().trim();
  const snap = await db
    .collection(PROJECT_INQUIRIES)
    .where("emailLower", "==", emailLower)
    .limit(50)
    .get();

  if (snap.empty) {
    return {claimed: 0};
  }

  const batch = db.batch();
  let claimed = 0;
  for (const doc of snap.docs) {
    if (doc.data().userId === caller.uid) continue;
    batch.update(doc.ref, {
      userId: caller.uid,
      claimedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    claimed++;
  }

  if (claimed > 0) {
    await batch.commit();
  }

  return {claimed};
});

/**
 * Admin-only bridge from a qualified inquiry into the existing order/project
 * workflow. The client must already have a verified 4iDeas account using the
 * same email address. Conversion is idempotent.
 */
export const convertProjectInquiryToOrder = onCall(async (request) => {
  requireAdmin(request);

  const inquiryId = readText(request.data?.inquiryId, "Inquiry id", 200);
  const inquiryRef = db.collection(PROJECT_INQUIRIES).doc(inquiryId);
  const inquirySnap = await inquiryRef.get();

  if (!inquirySnap.exists) {
    throw new HttpsError("not-found", "Project inquiry not found.");
  }

  const inquiry = inquirySnap.data()!;

  if (
    inquiry.status === "converted" &&
    typeof inquiry.linkedOrderId === "string" &&
    inquiry.linkedOrderId
  ) {
    return {
      orderId: inquiry.linkedOrderId,
      alreadyConverted: true,
    };
  }

  const emailLower =
    typeof inquiry.emailLower === "string"
      ? inquiry.emailLower
      : String(inquiry.email ?? "").toLowerCase().trim();

  if (!emailLower) {
    throw new HttpsError(
      "failed-precondition",
      "The inquiry does not have a valid email address."
    );
  }

  let client: UserRecord;
  try {
    client = await auth.getUserByEmail(emailLower);
  } catch {
    throw new HttpsError(
      "failed-precondition",
      "The client needs to create a 4iDeas account with this email before the inquiry can be converted.",
      {reason: "client_account_required"}
    );
  }

  if (!client.emailVerified) {
    throw new HttpsError(
      "failed-precondition",
      "The client account exists, but the email address is not verified yet.",
      {reason: "client_email_not_verified"}
    );
  }

  const orderRef = db.collection("orders").doc();
  const adminReply =
    typeof inquiry.adminReply === "string" ? inquiry.adminReply.trim() : "";
  const clientReply =
    typeof inquiry.clientReply === "string" ? inquiry.clientReply.trim() : "";

  const orderData: Record<string, unknown> = {
    userId: client.uid,
    clientName: String(inquiry.name ?? ""),
    clientEmail: String(inquiry.email ?? emailLower),
    clientPhone: "",
    clientCompany: String(inquiry.company ?? ""),
    appName: String(inquiry.projectType ?? "Project inquiry"),
    appType: String(inquiry.projectType ?? "Not specified"),
    appDescription: String(inquiry.message ?? ""),
    appFeatures: "",
    budget: String(inquiry.budgetRange ?? ""),
    timeline: String(inquiry.timeline ?? ""),
    priority: "Not specified",
    designStyle: "",
    designComplexity: "",
    selectedPlatforms: [],
    colorScheme: "",
    designInspiration: "",
    brandGuidelines: "",
    additionalNotes: `Imported from project inquiry ${inquiryId}`,
    sourceInquiryId: inquiryId,
    createdAt: FieldValue.serverTimestamp(),
    status: adminReply ? "responded" : "pending",
  };

  if (adminReply) {
    orderData.adminResponse = adminReply;
    orderData.adminResponseDate = FieldValue.serverTimestamp();
  }
  if (clientReply) {
    orderData.clientResponse = clientReply;
    orderData.clientResponseDate = FieldValue.serverTimestamp();
  }

  const batch = db.batch();
  batch.set(orderRef, orderData);
  batch.update(inquiryRef, {
    userId: client.uid,
    status: "converted",
    linkedOrderId: orderRef.id,
    convertedAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
  await batch.commit();

  return {
    orderId: orderRef.id,
    alreadyConverted: false,
  };
});
