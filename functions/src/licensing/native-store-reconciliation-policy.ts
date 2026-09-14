import type {LicenseStatus} from "./license-store";

const NATIVE_ONLY_LICENSE_SOURCES = new Set([
  "app_store",
  "google_play",
  "app_store_test",
  "google_play_test",
]);

export function isNativeOnlyLicenseSource(source: string): boolean {
  return NATIVE_ONLY_LICENSE_SOURCES.has(source.trim().toLowerCase());
}

export function shouldRevokeNativeLicense(params: {
  source: string;
  remainingActiveNativePurchases: number;
}): boolean {
  return (
    isNativeOnlyLicenseSource(params.source) &&
    params.remainingActiveNativePurchases === 0
  );
}

export function shouldReactivateNativeLicense(params: {
  source: string;
  status: LicenseStatus;
  revokedEvidenceHash: string | null;
  currentEvidenceHash: string;
}): boolean {
  return (
    isNativeOnlyLicenseSource(params.source) &&
    params.status === "revoked" &&
    params.revokedEvidenceHash === params.currentEvidenceHash
  );
}
