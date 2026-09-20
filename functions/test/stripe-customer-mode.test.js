const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const source = (relativePath) =>
  fs.readFileSync(path.join(__dirname, "..", "src", relativePath), "utf8");

test("saved Stripe customers are validated before checkout reuse", () => {
  const helper = source("stripe/customer.ts");
  assert.match(helper, /stripe\.customers\.retrieve\(savedCustomerId\)/);
  assert.match(helper, /candidate\.code === "resource_missing"/);
  assert.match(helper, /stripe\.customers\.create\(/);
});

test("both checkout paths use the mode-safe customer helper", () => {
  assert.match(
    source("stripe/checkout.ts"),
    /getOrCreateStripeCustomer\(stripe, uid, email\)/
  );
  assert.match(
    source("licensing/license-checkout.ts"),
    /getOrCreateStripeCustomer\(stripe, uid, email\)/
  );
});
