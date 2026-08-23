const test = require("node:test");
const assert = require("node:assert/strict");

const {
  DOWNLOADABLE_PRODUCTS,
  LINUX_PRODUCT_KEY,
  PRODUCT_KEY,
  SELLABLE_PRODUCT_KEYS,
  WEB_PRODUCT_KEY,
} = require("../lib/product-catalog.js");

test("Linux is sellable and maps only to the private Linux release prefix", () => {
  assert.ok(SELLABLE_PRODUCT_KEYS.includes(LINUX_PRODUCT_KEY));
  assert.deepEqual(DOWNLOADABLE_PRODUCTS[LINUX_PRODUCT_KEY], {
    platform: "linux",
    releasePrefix: "releases/linux",
    defaultFileName: "4iCAD_Linux.AppImage",
  });
});

test("desktop products have isolated release prefixes and Web has no installer", () => {
  assert.equal(DOWNLOADABLE_PRODUCTS[PRODUCT_KEY].releasePrefix, "releases/windows");
  assert.notEqual(
    DOWNLOADABLE_PRODUCTS[PRODUCT_KEY].releasePrefix,
    DOWNLOADABLE_PRODUCTS[LINUX_PRODUCT_KEY].releasePrefix
  );
  assert.equal(DOWNLOADABLE_PRODUCTS[WEB_PRODUCT_KEY], undefined);
});
