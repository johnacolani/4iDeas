/** Stable product keys shared by checkout, entitlement, and release flows. */
export const PRODUCT_KEY = "4icad_windows";
export const WEB_PRODUCT_KEY = "4icad_web";
export const LINUX_PRODUCT_KEY = "4icad_linux";

export type DownloadPlatform = "windows" | "linux";

export interface DownloadableProduct {
  platform: DownloadPlatform;
  releasePrefix: string;
  defaultFileName: string;
}

/** Legacy Windows prefix, retained for deployed clients and stored releases. */
export const RELEASE_PREFIX = "releases/windows";

/**
 * Trusted product-to-release mapping. Storage paths and platforms are resolved
 * here, never constructed from untrusted callable input.
 */
export const DOWNLOADABLE_PRODUCTS: Readonly<Record<string, DownloadableProduct>> = {
  [PRODUCT_KEY]: {
    platform: "windows",
    releasePrefix: RELEASE_PREFIX,
    defaultFileName: "4iCAD_Setup.exe",
  },
  [LINUX_PRODUCT_KEY]: {
    platform: "linux",
    releasePrefix: "releases/linux",
    defaultFileName: "4iCAD_Linux.AppImage",
  },
};

/** Products checkout may sell after server-side Stripe configuration exists. */
export const SELLABLE_PRODUCT_KEYS: readonly string[] = [
  PRODUCT_KEY,
  WEB_PRODUCT_KEY,
  LINUX_PRODUCT_KEY,
];
