/**
 * Trusted server-side layer for 4iCAD commerce.
 *
 * Everything that decides money or access lives here, never in the Flutter Web
 * client: the Stripe secret key, the price, promotion-code validity, webhook
 * verification, entitlement grants, and installer download authorization.
 */

export {bootstrapAdminClaim, setAdminClaim, listAdmins} from "./adminops/claims";
export {createCheckoutSession} from "./stripe/checkout";
export {stripeWebhook} from "./stripe/webhook";
export {createPromotionCode, listPromotionCodes, setPromotionCodeActive} from "./stripe/promotions";
export {getPurchaseStatus, getDownloadUrl} from "./downloads/download";
export {publishRelease, setCurrentRelease, onReleaseUploaded} from "./releases/releases";
