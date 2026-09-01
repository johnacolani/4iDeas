import {onCall, HttpsError} from "firebase-functions/v2/https";
import {requireAuth} from "../core";
import {
  activateDevice,
  deactivateDevice,
  getOwnerLicense,
} from "./license-store";
import {
  isLicensePlatform,
} from "./license-policy";

export const getMyLicense = onCall({region: "us-central1"}, async (req) => {
  const {uid} = requireAuth(req);
  const license = await getOwnerLicense(uid);
  if (!license) return {license: null};

  const data = license.data;
  return {
    license: {
      id: license.id,
      plan: data.plan,
      primaryPlatform: data.primaryPlatform,
      status: data.status,
      baseDeviceLimit: data.baseDeviceLimit,
      bonusOtherPlatformLimit: data.bonusOtherPlatformLimit,
      activeBaseDevices: data.activeBaseDevices ?? 0,
      activeBonusDevices: data.activeBonusDevices ?? 0,
    },
  };
});

export const activateMyDevice = onCall({region: "us-central1"}, async (req) => {
  const {uid} = requireAuth(req);
  const installationId = String(req.data?.installationId ?? "").trim();
  const platform = String(req.data?.platform ?? "").trim().toLowerCase();
  if (!installationId) {
    throw new HttpsError("invalid-argument", "installationId is required.");
  }
  if (!isLicensePlatform(platform)) {
    throw new HttpsError("invalid-argument", "Unsupported platform.");
  }

  return activateDevice(uid, {
    installationId,
    platform,
    deviceName: req.data?.deviceName ? String(req.data.deviceName).trim() : null,
    appVersion: req.data?.appVersion ? String(req.data.appVersion).trim() : null,
  });
});

export const deactivateMyDevice = onCall({region: "us-central1"}, async (req) => {
  const {uid} = requireAuth(req);
  const installationId = String(req.data?.installationId ?? "").trim();
  if (!installationId) {
    throw new HttpsError("invalid-argument", "installationId is required.");
  }
  return deactivateDevice(uid, installationId);
});
