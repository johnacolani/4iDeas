import {encode} from "html-entities";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {db, FieldValue, GMAIL_APP_PASSWORD, requireAdmin, SITE_ORIGIN} from "../core";
import {sendGmailEmail} from "../email/gmail-smtp";

const PROJECT_INQUIRIES = "project_inquiries";
const SHARED_FILES = "shared_files";

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

function isExpired(value: unknown): boolean {
  if (!value || typeof value !== "object") return false;
  const maybe = value as {toMillis?: () => number};
  return typeof maybe.toMillis === "function" && maybe.toMillis() <= Date.now();
}

/**
 * Saves the admin response and sends the matching email directly through Gmail
 * SMTP. The App Password is injected from Secret Manager at runtime and is
 * never stored in source code or Firestore.
 */
export const sendProjectInquiryResponse = onCall(
  {
    secrets: [GMAIL_APP_PASSWORD],
    timeoutSeconds: 60,
  },
  async (request) => {
  requireAdmin(request);

  const inquiryId = readText(request.data?.inquiryId, "Inquiry id", 200);
  const response = readText(request.data?.response, "Response", 8000);
  const adminNotes = readText(
    request.data?.adminNotes ?? "",
    "Admin notes",
    5000,
    false
  );

  const inquiryRef = db.collection(PROJECT_INQUIRIES).doc(inquiryId);
  const inquirySnap = await inquiryRef.get();
  if (!inquirySnap.exists) {
    throw new HttpsError("not-found", "Project inquiry not found.");
  }

  const inquiry = inquirySnap.data()!;
  const email =
    typeof inquiry.email === "string" ? inquiry.email.trim() : "";
  if (!email) {
    throw new HttpsError(
      "failed-precondition",
      "This inquiry does not have an email address."
    );
  }

  const name =
    typeof inquiry.name === "string" && inquiry.name.trim()
      ? inquiry.name.trim()
      : "there";

  const fileSnap = await db
    .collection(SHARED_FILES)
    .where("inquiryId", "==", inquiryId)
    .limit(25)
    .get();

  const links = fileSnap.docs
    .map((doc) => doc.data())
    .filter((file) => file.active === true && !isExpired(file.expiresAt))
    .map((file) => {
      const slug = typeof file.slug === "string" ? file.slug.trim() : "";
      const title =
        typeof file.title === "string" && file.title.trim()
          ? file.title.trim()
          : typeof file.fileName === "string"
            ? file.fileName
            : "Shared file";
      return slug
        ? {
            title,
            url: `${SITE_ORIGIN}/share/${slug
              .split("/")
              .map(encodeURIComponent)
              .join("/")}`,
          }
        : null;
    })
    .filter((item): item is {title: string; url: string} => item !== null);

  const profileUrl = `${SITE_ORIGIN}/profile`;
  const textFiles =
    links.length === 0
      ? ""
      : `\n\nFiles from 4iDeas:\n${links
          .map((item) => `- ${item.title}: ${item.url}`)
          .join("\n")}`;

  const text = `Hi ${name},

${response}${textFiles}

You can also sign in to 4iDeas to track this inquiry and reply:
${profileUrl}

Best regards,
John
4iDeas
info@4ideasapp.com`;

  const htmlFiles =
    links.length === 0
      ? ""
      : `<div style="margin:24px 0 8px"><strong>Files from 4iDeas</strong></div><ul>${links
          .map(
            (item) =>
              `<li><a href="${encode(item.url)}">${encode(item.title)}</a></li>`
          )
          .join("")}</ul>`;

  const html = `<div style="font-family:Arial,sans-serif;line-height:1.6;color:#1f2937">
<p>Hi ${encode(name)},</p>
<p>${encode(response).replace(/\n/g, "<br>")}</p>
${htmlFiles}
<p><a href="${encode(profileUrl)}">Sign in to 4iDeas</a> to track this inquiry and reply.</p>
<p>Best regards,<br>John<br>4iDeas<br><a href="mailto:info@4ideasapp.com">info@4ideasapp.com</a></p>
</div>`;

  let delivery;
  try {
    delivery = await sendGmailEmail({
      to: email,
      subject: "A response from 4iDeas about your project",
      text,
      html,
      appPassword: GMAIL_APP_PASSWORD.value(),
    });
  } catch (error) {
    console.error("Project inquiry email delivery failed", {
      inquiryId,
      error: error instanceof Error ? error.message : String(error),
    });
    throw new HttpsError(
      "internal",
      "The response was not sent. Please try again."
    );
  }

  await inquiryRef.update({
    adminReply: response,
    adminNotes,
    status: "awaiting_client",
    adminRepliedAt: FieldValue.serverTimestamp(),
    emailSentAt: FieldValue.serverTimestamp(),
    emailMessageId: delivery.messageId,
    updatedAt: FieldValue.serverTimestamp(),
  });

  return {
    sent: true,
    fileCount: links.length,
    messageId: delivery.messageId,
  };
  }
);
