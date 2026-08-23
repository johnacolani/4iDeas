import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onObjectFinalized} from "firebase-functions/v2/storage";
import {logger} from "firebase-functions";
import {createHash} from "crypto";
import {
  COL,
  DOWNLOADABLE_PRODUCTS,
  FieldValue,
  PRODUCT_KEY,
  db,
  requireAdmin,
  storage,
} from "../core";

/** Accepts 1.0.8, 1.0.8.2, 2.1, and optional pre-release suffixes like 1.2.0-beta.1 */
const VERSION_RE = /^\d+(\.\d+){1,3}(-[0-9A-Za-z.-]+)?$/;

/**
 * Copies the Current release's public-safe fields onto the product document so
 * the public page can show the latest version without ever being able to
 * read the release collection (which holds the private storage path).
 */
async function syncCurrentReleaseToProduct(productKey: string) {
  const downloadable = DOWNLOADABLE_PRODUCTS[productKey];
  if (!downloadable) return;
  const q = await db
    .collection(COL.releases)
    .where("productKey", "==", productKey)
    .where("platform", "==", downloadable.platform)
    .where("isCurrent", "==", true)
    .limit(1)
    .get();

  if (q.empty) {
    await db.collection(COL.products).doc(productKey).set({currentRelease: null}, {merge: true});
    return;
  }
  const r = q.docs[0];
  const d = r.data();
  await db.collection(COL.products).doc(productKey).set(
    {
      currentRelease: {
        releaseId: r.id,
        version: d.version ?? null,
        publishedAt: d.publishedAt ?? null,
        fileSizeBytes: d.fileSizeBytes ?? null,
        sha256: d.sha256 ?? null,
        releaseNotes: d.releaseNotes ?? null,
        // Deliberately omits storagePath — that must never reach a browser.
      },
      updatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true}
  );
}

/**
 * Registers an already-uploaded installer as a release.
 *
 * The admin client uploads the binary straight to the private release prefix
 * (Storage rules permit admin writes there), then calls this to create the
 * metadata document. Validation lives here rather than in the browser.
 */
export const publishRelease = onCall({region: "us-central1"}, async (req) => {
  const admin = requireAdmin(req);

  const version = String(req.data?.version ?? "").trim();
  const storagePath = String(req.data?.storagePath ?? "").trim();
  const originalFileName = String(req.data?.originalFileName ?? "").trim();
  const releaseNotes = String(req.data?.releaseNotes ?? "").trim();
  const fileSizeBytes = Number(req.data?.fileSizeBytes ?? 0);
  const makeCurrent = req.data?.makeCurrent !== false;
  const productKey = String(req.data?.productKey ?? PRODUCT_KEY);
  const downloadable = DOWNLOADABLE_PRODUCTS[productKey];

  if (!VERSION_RE.test(version)) {
    throw new HttpsError("invalid-argument", "Enter a version like 1.0.8.");
  }
  if (!downloadable) {
    throw new HttpsError("invalid-argument", "Unknown downloadable product.");
  }
  if (!storagePath.startsWith(`${downloadable.releasePrefix}/`)) {
    throw new HttpsError("invalid-argument", "The installer must be in the release folder.");
  }
  const lowerName = originalFileName.toLowerCase();
  const validFile = downloadable.platform === "windows"
    ? lowerName.endsWith(".exe")
    : lowerName.endsWith(".appimage") || lowerName.endsWith(".deb") ||
      lowerName.endsWith(".tar.gz");
  if (!validFile) {
    throw new HttpsError(
      "invalid-argument",
      downloadable.platform === "windows"
        ? "The installer must be a .exe file."
        : "The Linux package must be an .AppImage, .deb, or .tar.gz file."
    );
  }
  if (!releaseNotes) {
    throw new HttpsError("invalid-argument", "Release notes are required.");
  }
  if (!Number.isFinite(fileSizeBytes) || fileSizeBytes <= 0) {
    throw new HttpsError("invalid-argument", "The uploaded file appears to be empty.");
  }

  // The object must genuinely exist before we advertise a version.
  const [exists] = await storage.bucket().file(storagePath).exists();
  if (!exists) {
    throw new HttpsError("not-found", "The uploaded installer could not be found in storage.");
  }

  const dupe = await db
    .collection(COL.releases)
    .where("productKey", "==", productKey)
    .where("platform", "==", downloadable.platform)
    .where("version", "==", version)
    .limit(1)
    .get();
  if (!dupe.empty) {
    throw new HttpsError("already-exists", `Version ${version} has already been published.`);
  }

  const ref = db.collection(COL.releases).doc();
  await ref.set({
    productKey,
    platform: downloadable.platform,
    version,
    storagePath,
    originalFileName,
    fileSizeBytes,
    releaseNotes,
    sha256: null, // filled in by the storage trigger
    isCurrent: false,
    publishedAt: FieldValue.serverTimestamp(),
    createdAt: FieldValue.serverTimestamp(),
    createdByUid: admin.uid,
    createdByEmail: admin.email,
  });

  if (makeCurrent) {
    await setCurrent(ref.id, productKey, downloadable.platform);
  }
  await syncCurrentReleaseToProduct(productKey);

  logger.info("release published", {releaseId: ref.id, version});
  return {releaseId: ref.id, version, isCurrent: makeCurrent};
});

/** Flips exactly one release to Current inside a batch. Nothing is deleted. */
async function setCurrent(releaseId: string, productKey: string, platform: string) {
  const all = await db
    .collection(COL.releases)
    .where("productKey", "==", productKey)
    .where("platform", "==", platform)
    .get();

  const batch = db.batch();
  let found = false;
  for (const doc of all.docs) {
    const shouldBeCurrent = doc.id === releaseId;
    if (shouldBeCurrent) found = true;
    if ((doc.data().isCurrent === true) !== shouldBeCurrent) {
      batch.update(doc.ref, {isCurrent: shouldBeCurrent});
    }
  }
  if (!found) {
    throw new HttpsError("not-found", "That release does not exist.");
  }
  await batch.commit();
}

/**
 * Rollback and roll-forward are the same operation: designate any existing
 * release as Current. Previous binaries are always retained.
 */
export const setCurrentRelease = onCall({region: "us-central1"}, async (req) => {
  requireAdmin(req);
  const releaseId = String(req.data?.releaseId ?? "");
  const productKey = String(req.data?.productKey ?? PRODUCT_KEY);
  const downloadable = DOWNLOADABLE_PRODUCTS[productKey];
  if (!releaseId) throw new HttpsError("invalid-argument", "A release id is required.");
  if (!downloadable) throw new HttpsError("invalid-argument", "Unknown downloadable product.");

  await setCurrent(releaseId, productKey, downloadable.platform);
  await syncCurrentReleaseToProduct(productKey);
  logger.info("current release changed", {releaseId});
  return {ok: true, releaseId};
});

/**
 * Computes SHA-256 server-side once the binary lands. Hashing hundreds of
 * megabytes in the browser is unreliable, so the admin never supplies it.
 */
export const onReleaseUploaded = onObjectFinalized(
  {region: "us-central1", memory: "1GiB", timeoutSeconds: 540},
  async (event) => {
    const path = event.data.name;
    if (!path || !Object.values(DOWNLOADABLE_PRODUCTS).some(
      (product) => path.startsWith(`${product.releasePrefix}/`)
    )) return;

    const q = await db.collection(COL.releases).where("storagePath", "==", path).limit(1).get();
    if (q.empty) {
      logger.debug("uploaded release object has no metadata document yet", {path});
      return;
    }

    const hash = createHash("sha256");
    await new Promise<void>((resolve, reject) => {
      storage
        .bucket(event.data.bucket)
        .file(path)
        .createReadStream()
        .on("data", (chunk: Buffer) => hash.update(chunk))
        .on("end", () => resolve())
        .on("error", reject);
    });
    const sha256 = hash.digest("hex");

    await q.docs[0].ref.update({sha256});
    await syncCurrentReleaseToProduct(q.docs[0].data().productKey ?? PRODUCT_KEY);
    logger.info("release checksum computed", {path, releaseId: q.docs[0].id});
  }
);
