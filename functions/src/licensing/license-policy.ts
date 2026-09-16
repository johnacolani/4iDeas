export type LicensePlan = "individual" | "company";

export type DevicePlatform =
  | "windows"
  | "macos"
  | "linux"
  | "ios"
  | "android";

export type WebCheckoutPrimaryPlatform = "windows" | "macos" | "linux";

export interface LicensePlanPolicy {
  plan: LicensePlan;
  primaryDeviceLimit: number;
  bonusOtherPlatformLimit: number;
  totalDeviceLimit: number;
}

export interface ActivationUsage {
  primaryActive: number;
  bonusActive: number;
}

export type ActivationBucket = "primary" | "bonus";

export interface ActivationDecision {
  allowed: boolean;
  bucket: ActivationBucket;
  reason: "available" | "primary_limit_reached" | "bonus_limit_reached";
}

/**
 * The first production licensing rules agreed for 4iCAD.
 *
 * Individual: one device on the purchased primary platform plus one free
 * activation on a different platform.
 * Company: ten devices on the purchased primary platform plus three free
 * activations on different platforms.
 *
 * Web is intentionally not a DevicePlatform yet. Browser licensing needs a
 * separate session/browser policy so clearing browser storage cannot silently
 * consume or manufacture device seats. Until that policy is finalized, this
 * module governs native installations only.
 */
export const LICENSE_PLAN_POLICIES: Record<LicensePlan, LicensePlanPolicy> = {
  individual: {
    plan: "individual",
    primaryDeviceLimit: 1,
    bonusOtherPlatformLimit: 1,
    totalDeviceLimit: 2,
  },
  company: {
    plan: "company",
    primaryDeviceLimit: 10,
    bonusOtherPlatformLimit: 3,
    totalDeviceLimit: 13,
  },
};

const DEVICE_PLATFORMS = new Set<DevicePlatform>([
  "windows",
  "macos",
  "linux",
  "ios",
  "android",
]);

const WEB_CHECKOUT_PRIMARY_PLATFORMS = new Set<WebCheckoutPrimaryPlatform>([
  "windows",
  "macos",
  "linux",
]);

export function isLicensePlan(value: unknown): value is LicensePlan {
  return value === "individual" || value === "company";
}

export function isDevicePlatform(value: unknown): value is DevicePlatform {
  return typeof value === "string" && DEVICE_PLATFORMS.has(value as DevicePlatform);
}

/**
 * Primary platforms that may be purchased directly on 4ideasapp.com.
 * iOS and Android remain valid device platforms for cross-platform activations,
 * but their storefront purchase path is handled by the respective app stores.
 */
export function isWebCheckoutPrimaryPlatform(
  value: unknown
): value is WebCheckoutPrimaryPlatform {
  return (
    typeof value === "string" &&
    WEB_CHECKOUT_PRIMARY_PLATFORMS.has(value as WebCheckoutPrimaryPlatform)
  );
}

export function getLicensePlanPolicy(plan: LicensePlan): LicensePlanPolicy {
  return LICENSE_PLAN_POLICIES[plan];
}

/**
 * Decide which seat bucket a NEW activation would consume.
 * Existing device re-activation is handled before this policy is called and
 * must never consume another seat.
 */
export function decideNewActivation(
  plan: LicensePlan,
  primaryPlatform: DevicePlatform,
  requestedPlatform: DevicePlatform,
  usage: ActivationUsage
): ActivationDecision {
  const policy = getLicensePlanPolicy(plan);
  const isPrimary = requestedPlatform === primaryPlatform;

  if (isPrimary) {
    return usage.primaryActive < policy.primaryDeviceLimit
      ? {allowed: true, bucket: "primary", reason: "available"}
      : {
          allowed: false,
          bucket: "primary",
          reason: "primary_limit_reached",
        };
  }

  return usage.bonusActive < policy.bonusOtherPlatformLimit
    ? {allowed: true, bucket: "bonus", reason: "available"}
    : {
        allowed: false,
        bucket: "bonus",
        reason: "bonus_limit_reached",
      };
}
