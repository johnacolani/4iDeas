import {onRequest} from "firebase-functions/v2/https";

import {db, FieldValue, SITE_ORIGIN, storage} from "../core";

const SHARED_FILES = "shared_files";
const SIGNED_URL_TTL_MS = 15 * 60 * 1000;

function shareSlugFromRequest(req: {originalUrl?: string; url: string}): string {
  const raw = req.originalUrl || req.url || "";
  const path = new URL(raw, SITE_ORIGIN).pathname;
  const marker = "/share/";
  const index = path.indexOf(marker);
  if (index < 0) return "";
  try {
    return decodeURIComponent(path.slice(index + marker.length))
      .replace(/^\/+|\/+$/g, "")
      .trim();
  } catch {
    return "";
  }
}

function isExpired(value: unknown): boolean {
  if (!value || typeof value !== "object") return false;
  const maybe = value as {toMillis?: () => number};
  if (typeof maybe.toMillis !== "function") return false;
  return maybe.toMillis() <= Date.now();
}

/**
 * Public 4ideasapp.com/share/* gateway.
 *
 * Storage remains private. This endpoint validates the Firestore share record,
 * creates a short-lived V4 signed URL, then redirects the browser to the file.
 * Public/unlisted Apple-review links therefore stay on the 4iDeas domain while
 * never exposing a permanent Firebase download token.
 */
export const sharedFileRedirect = onRequest(async (req, res) => {
  res.set("Cache-Control", "no-store, max-age=0");
  res.set("X-Robots-Tag", "noindex, nofollow, noarchive");

  if (req.method !== "GET" && req.method !== "HEAD") {
    res.status(405).send("Method not allowed");
    return;
  }

  const slug = shareSlugFromRequest(req);
  if (!slug) {
    res.status(404).send("Shared file not found.");
    return;
  }

  const snap = await db
    .collection(SHARED_FILES)
    .where("slug", "==", slug)
    .limit(1)
    .get();

  if (snap.empty) {
    res.status(404).send("Shared file not found.");
    return;
  }

  const doc = snap.docs[0];
  const data = doc.data();
  if (data.active !== true || isExpired(data.expiresAt)) {
    res.status(410).send("This shared link is no longer available.");
    return;
  }

  const storagePath =
    typeof data.storagePath === "string" ? data.storagePath.trim() : "";
  if (!storagePath) {
    res.status(404).send("Shared file is unavailable.");
    return;
  }

  const file = storage.bucket().file(storagePath);
  const [exists] = await file.exists();
  if (!exists) {
    res.status(404).send("Shared file is unavailable.");
    return;
  }

  const [url] = await file.getSignedUrl({
    version: "v4",
    action: "read",
    expires: Date.now() + SIGNED_URL_TTL_MS,
    responseDisposition:
      typeof data.fileName === "string" && data.fileName
        ? `inline; filename="${String(data.fileName).replace(/"/g, "")}"`
        : "inline",
  });

  void doc.ref.set(
    {
      lastAccessedAt: FieldValue.serverTimestamp(),
      accessCount: FieldValue.increment(1),
    },
    {merge: true}
  );

  res.redirect(302, url);
});
