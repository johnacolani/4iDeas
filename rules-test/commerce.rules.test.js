/**
 * Security rules tests for the 4iCAD commerce data model.
 *
 * Actor classes covered: anonymous public, authenticated non-owner, entitled
 * owner, admin (custom claim), and legacy-email admin. Each is checked for both
 * what it must be able to do and what it must not.
 *
 * Run with:  npm --prefix rules-test test
 */

const {test, before, after, beforeEach, describe} = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require("@firebase/rules-unit-testing");
const {
  doc, getDoc, setDoc, deleteDoc, collection, getDocs, query, where,
} = require("firebase/firestore");
const {ref, getBytes, uploadBytes} = require("firebase/storage");

const PRODUCT = "4icad_windows";
const OWNER_UID = "buyer-owns";
const OTHER_UID = "buyer-none";
const ADMIN_UID = "admin-claim";
const LEGACY_UID = "admin-legacy";
const LEGACY_EMAIL = "john.ace.colani@outlook.com";
const SESSION_OWNED = "cs_test_owned";
const SESSION_OTHER = "cs_test_other";
const ENT_OWNED = `${OWNER_UID}__${PRODUCT}`;

let testEnv;

// Contexts
const anon = () => testEnv.unauthenticatedContext();
const owner = () => testEnv.authenticatedContext(OWNER_UID, {email: "owner@example.com"});
const other = () => testEnv.authenticatedContext(OTHER_UID, {email: "other@example.com"});
const admin = () => testEnv.authenticatedContext(ADMIN_UID, {email: "a@example.com", admin: true});
const legacyAdmin = () => testEnv.authenticatedContext(LEGACY_UID, {email: LEGACY_EMAIL});

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: "demo-4ideas",
    firestore: {
      rules: fs.readFileSync(path.resolve(__dirname, "../firestore.rules"), "utf8"),
    },
    storage: {
      rules: fs.readFileSync(path.resolve(__dirname, "../storage.rules"), "utf8"),
    },
  });
});

after(async () => {
  if (testEnv) await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  // Seed as the backend would (Admin SDK bypasses rules).
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "products", PRODUCT), {
      displayName: "4iCAD for Windows",
      active: true,
      currentRelease: {releaseId: "rel1", version: "1.0.8"},
    });
    await setDoc(doc(db, "product_config", PRODUCT), {
      stripePriceId: "price_test_123",
      stripeProductId: "prod_test_123",
    });
    await setDoc(doc(db, "releases", "rel1"), {
      productKey: PRODUCT,
      platform: "windows",
      version: "1.0.8",
      isCurrent: true,
      storagePath: "releases/windows/1.0.8/4iCAD_Setup.exe",
    });
    await setDoc(doc(db, "product_orders", SESSION_OWNED), {
      uid: OWNER_UID, productKey: PRODUCT, status: "completed", amountPaid: 4900,
    });
    await setDoc(doc(db, "product_orders", SESSION_OTHER), {
      uid: "someone-else", productKey: PRODUCT, status: "completed", amountPaid: 4900,
    });
    await setDoc(doc(db, "entitlements", ENT_OWNED), {
      uid: OWNER_UID, productKey: PRODUCT, active: true,
    });
    await setDoc(doc(db, "web_trials", OWNER_UID), {
      uid: OWNER_UID, productKey: PRODUCT, startedAt: new Date(), launchCount: 1,
    });
    await setDoc(doc(db, "stripe_events", "evt_1"), {status: "processed"});
    await setDoc(doc(db, "stripe_customers", OWNER_UID), {customerId: "cus_123"});
    await setDoc(doc(db, "download_audit", "dl1"), {uid: OWNER_UID});
  });
});

describe("products — public display data", () => {
  test("anyone may read the product, including the current version", async () => {
    const snap = await assertSucceeds(getDoc(doc(anon().firestore(), "products", PRODUCT)));
    assert.strictEqual(snap.data().currentRelease.version, "1.0.8");
  });

  test("nobody may write it from a client — not even an admin", async () => {
    await assertFails(setDoc(doc(anon().firestore(), "products", PRODUCT), {displayName: "x"}));
    await assertFails(setDoc(doc(owner().firestore(), "products", PRODUCT), {displayName: "x"}));
    await assertFails(setDoc(doc(admin().firestore(), "products", PRODUCT), {displayName: "x"}));
  });
});

describe("product_config — server-only Stripe Price", () => {
  test("no client may read the Stripe Price id", async () => {
    await assertFails(getDoc(doc(anon().firestore(), "product_config", PRODUCT)));
    await assertFails(getDoc(doc(owner().firestore(), "product_config", PRODUCT)));
    await assertFails(getDoc(doc(admin().firestore(), "product_config", PRODUCT)));
  });

  test("no client may write it", async () => {
    await assertFails(setDoc(doc(admin().firestore(), "product_config", PRODUCT), {
      stripePriceId: "price_attacker",
    }));
  });
});

describe("releases — private storage path", () => {
  test("public and ordinary buyers cannot read release records", async () => {
    await assertFails(getDoc(doc(anon().firestore(), "releases", "rel1")));
    await assertFails(getDoc(doc(owner().firestore(), "releases", "rel1")));
  });

  test("admins may read release history", async () => {
    await assertSucceeds(getDoc(doc(admin().firestore(), "releases", "rel1")));
  });

  test("legacy-email admin may still read during migration", async () => {
    await assertSucceeds(getDoc(doc(legacyAdmin().firestore(), "releases", "rel1")));
  });

  test("no client may write a release", async () => {
    await assertFails(setDoc(doc(admin().firestore(), "releases", "rel2"), {version: "9.9.9"}));
  });
});

describe("product_orders — payment truth", () => {
  test("a buyer may read their own order", async () => {
    await assertSucceeds(getDoc(doc(owner().firestore(), "product_orders", SESSION_OWNED)));
  });

  test("a buyer may not read someone else's order", async () => {
    await assertFails(getDoc(doc(owner().firestore(), "product_orders", SESSION_OTHER)));
  });

  test("anonymous visitors may not read orders", async () => {
    await assertFails(getDoc(doc(anon().firestore(), "product_orders", SESSION_OWNED)));
  });

  test("an admin may read all orders", async () => {
    await assertSucceeds(getDoc(doc(admin().firestore(), "product_orders", SESSION_OTHER)));
  });

  test("a buyer may query only their own orders", async () => {
    const db = owner().firestore();
    await assertSucceeds(getDocs(
      query(collection(db, "product_orders"), where("uid", "==", OWNER_UID))
    ));
    await assertFails(getDocs(collection(db, "product_orders")));
  });

  test("nobody may forge or edit an order", async () => {
    await assertFails(setDoc(doc(other().firestore(), "product_orders", "cs_forged"), {
      uid: OTHER_UID, productKey: PRODUCT, status: "completed",
    }));
    await assertFails(setDoc(doc(owner().firestore(), "product_orders", SESSION_OWNED), {
      amountPaid: 0,
    }));
    await assertFails(setDoc(doc(admin().firestore(), "product_orders", SESSION_OWNED), {
      amountPaid: 0,
    }));
    await assertFails(deleteDoc(doc(admin().firestore(), "product_orders", SESSION_OWNED)));
  });
});

describe("entitlements — the access decision", () => {
  test("an owner may read their own entitlement", async () => {
    const snap = await assertSucceeds(
      getDoc(doc(owner().firestore(), "entitlements", ENT_OWNED))
    );
    assert.strictEqual(snap.data().active, true);
  });

  test("a non-owner may not read someone else's entitlement", async () => {
    await assertFails(getDoc(doc(other().firestore(), "entitlements", ENT_OWNED)));
  });

  test("anonymous visitors may not read entitlements", async () => {
    await assertFails(getDoc(doc(anon().firestore(), "entitlements", ENT_OWNED)));
  });

  test("a user cannot grant themselves an entitlement", async () => {
    await assertFails(setDoc(doc(other().firestore(), "entitlements", `${OTHER_UID}__${PRODUCT}`), {
      uid: OTHER_UID, productKey: PRODUCT, active: true,
    }));
  });

  test("even an admin cannot mint an entitlement from the browser", async () => {
    await assertFails(setDoc(doc(admin().firestore(), "entitlements", `${OTHER_UID}__${PRODUCT}`), {
      uid: OTHER_UID, productKey: PRODUCT, active: true,
    }));
  });
});

describe("web_trials — the 48-hour clock", () => {
  test("a visitor may read their own trial window for the countdown", async () => {
    const snap = await assertSucceeds(
      getDoc(doc(owner().firestore(), "web_trials", OWNER_UID))
    );
    assert.strictEqual(snap.data().launchCount, 1);
  });

  test("nobody may read someone else's trial", async () => {
    await assertFails(getDoc(doc(other().firestore(), "web_trials", OWNER_UID)));
    await assertFails(getDoc(doc(anon().firestore(), "web_trials", OWNER_UID)));
  });

  test("a visitor cannot start their own clock", async () => {
    await assertFails(setDoc(doc(other().firestore(), "web_trials", OTHER_UID), {
      uid: OTHER_UID, productKey: PRODUCT, startedAt: new Date(),
    }));
  });

  test("a visitor cannot push their start time forward to extend the trial", async () => {
    await assertFails(setDoc(doc(owner().firestore(), "web_trials", OWNER_UID), {
      uid: OWNER_UID, productKey: PRODUCT, startedAt: new Date(),
    }));
  });

  test("not even an admin may write a trial window from the browser", async () => {
    await assertFails(setDoc(doc(admin().firestore(), "web_trials", OTHER_UID), {
      uid: OTHER_UID, startedAt: new Date(),
    }));
  });
});

describe("backend bookkeeping is not client-readable", () => {
  test("stripe_events and stripe_customers are closed to everyone", async () => {
    await assertFails(getDoc(doc(admin().firestore(), "stripe_events", "evt_1")));
    await assertFails(getDoc(doc(owner().firestore(), "stripe_customers", OWNER_UID)));
    await assertFails(getDoc(doc(admin().firestore(), "stripe_customers", OWNER_UID)));
  });

  test("download audit is admin-readable, never client-writable", async () => {
    await assertSucceeds(getDoc(doc(admin().firestore(), "download_audit", "dl1")));
    await assertFails(getDoc(doc(owner().firestore(), "download_audit", "dl1")));
    await assertFails(setDoc(doc(admin().firestore(), "download_audit", "dl2"), {uid: "x"}));
  });
});

describe("existing collections still behave", () => {
  test("portfolio content stays publicly readable and admin-writable", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "portfolio_case_studies", "cs1"), {title: "ASD"});
    });
    await assertSucceeds(getDoc(doc(anon().firestore(), "portfolio_case_studies", "cs1")));
    await assertSucceeds(
      setDoc(doc(admin().firestore(), "portfolio_case_studies", "cs1"), {title: "ASD 2"})
    );
    await assertFails(
      setDoc(doc(other().firestore(), "portfolio_case_studies", "cs1"), {title: "hacked"})
    );
  });

  test("privacy policies remain publicly readable", async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "privacy_policies", "p1"), {slug: "4icad"});
    });
    await assertSucceeds(getDoc(doc(anon().firestore(), "privacy_policies", "p1")));
    await assertFails(setDoc(doc(other().firestore(), "privacy_policies", "p1"), {slug: "x"}));
  });
});

describe("storage — the paid installer", () => {
  const INSTALLER = "releases/windows/1.0.8/4iCAD_Setup.exe";

  beforeEach(async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await uploadBytes(
        ref(ctx.storage(), INSTALLER),
        new Uint8Array([77, 90, 0, 0]),
        {contentType: "application/vnd.microsoft.portable-executable"}
      );
    });
  });

  test("the installer is unreadable by every client class", async () => {
    await assertFails(getBytes(ref(anon().storage(), INSTALLER)));
    await assertFails(getBytes(ref(other().storage(), INSTALLER)));
    // An entitled owner also cannot read it directly — access is only ever
    // granted through a short-lived signed URL from the backend.
    await assertFails(getBytes(ref(owner().storage(), INSTALLER)));
    await assertFails(getBytes(ref(admin().storage(), INSTALLER)));
  });

  test("only an admin may upload an installer", async () => {
    const bytes = new Uint8Array([77, 90, 0, 0]);
    const meta = {contentType: "application/vnd.microsoft.portable-executable"};
    await assertFails(
      uploadBytes(ref(anon().storage(), "releases/windows/9.9.9/x.exe"), bytes, meta)
    );
    await assertFails(
      uploadBytes(ref(owner().storage(), "releases/windows/9.9.9/x.exe"), bytes, meta)
    );
    await assertSucceeds(
      uploadBytes(ref(admin().storage(), "releases/windows/9.9.9/x.exe"), bytes, meta)
    );
  });

  test("existing image upload rules are unchanged", async () => {
    const png = new Uint8Array([137, 80, 78, 71]);
    await assertSucceeds(uploadBytes(
      ref(admin().storage(), "admin_uploads/case-study-heroes/a.png"),
      png,
      {contentType: "image/png"}
    ));
    await assertFails(uploadBytes(
      ref(other().storage(), "admin_uploads/case-study-heroes/b.png"),
      png,
      {contentType: "image/png"}
    ));
    // Images stay publicly readable, as the portfolio depends on.
    await assertSucceeds(getBytes(ref(anon().storage(), "admin_uploads/case-study-heroes/a.png")));
  });

  test("legacy-email admin can still upload during the claim migration", async () => {
    // Regression guard: an absent `admin` claim must evaluate false, not raise
    // an evaluation error, or this admin would be locked out mid-migration.
    await assertSucceeds(uploadBytes(
      ref(legacyAdmin().storage(), "releases/windows/9.9.8/legacy.exe"),
      new Uint8Array([77, 90, 0, 0]),
      {contentType: "application/vnd.microsoft.portable-executable"}
    ));
  });

  test("a non-executable cannot be smuggled into the release path", async () => {
    await assertFails(uploadBytes(
      ref(admin().storage(), "releases/windows/9.9.9/evil.png"),
      new Uint8Array([137, 80, 78, 71]),
      {contentType: "image/png"}
    ));
  });
});
