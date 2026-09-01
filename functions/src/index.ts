/**
 * Trusted server-side layer for 4iCAD commerce.
 *
 * Everything that decides money or access lives here, never in the Flutter Web
 * client: the Stripe secret key, the price, promotion-code validity, webhook
 * verification, entitlement grants, installer download authorization, and the
 * 48-hour web-app trial window.
 */

export {bootstrapAdminClaim, setAdminClaim, listAdmins} from "./adminops/claims";
export {createCheckoutSession} from "./stripe/checkout";
export {stripeWebhook} from "./stripe/webhook";
export {
  createPromotionCode,
  listPromotionCodes,
  setPromotionCodeActive,
  restockPromotionCodes,
  assignPromotionCode,
} from "./stripe/promotions";
export {getPurchaseStatus, getDownloadUrl} from "./downloads/download";
export {startWebTrial, verifyWebTrial} from "./trials/web-trial";
export {publishRelease, setCurrentRelease, onReleaseUploaded} from "./releases/releases";
export {setPlatformStoreListing} from "./platforms/store-listings";
export {getLicensePlans} from "./licensing/license-catalog";
export {createLicenseCheckoutSession} from "./licensing/license-checkout";
export {getLicensePurchaseStatus} from "./licensing/license-status";
export {
  getMyLicense,
  activateMyDevice,
  deactivateMyDevice,
} from "./licensing/license-functions";
export {
  listLicenses,
  getLicenseDevices,
  grantComplimentaryLicense,
  setLicenseStatus,
  adminDeactivateDevice,
} from "./licensing/license-admin";
