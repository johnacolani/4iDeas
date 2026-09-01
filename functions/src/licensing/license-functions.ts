import {onCall, HttpsError} from "firebase-functions/v2/https";
import {requireAuth} from "../core";
import {
  activateDevice,
  deactivateDevice,
  getOwnerLicense,
  listOwnerDevices,
} from "./license-store";
import {isDevicePlatform} from "./license-policy";

function timestampMillis(value: unknown): number | null {
  if (
    value &&
    typeof value === "object" &&
    "toMillis" in value &&
    typeof (value as {toMillis?: unknown}).toMillis === "function"
  ) {
    return (value as {toMillis: () => number}).toMillis();
  }
  return null;
}

export const getMyLicense = onCall({region: "us-central1"}, async (req) => {
  const {uid} = requireAuth(req);
  const license = await getOwnerLicense(uid);
  if (!license) return {license: null, devices: []};

  const data = license.data;
  const devices = await listOwnerDevices(uid);
  return {
    license: {
      id: license.id,
      plan: data.plan,
      primaryPlatform: data.primaryPlatform,
      status: data.status,
      primaryDeviceLimit: data.primaryDeviceLimit,
      bonusOtherPlatformLimit: data.bonusOtherPlatformLimit,
      totalDeviceLimit: data.totalDeviceLimit,
      activePrimaryDevices: data.activePrimaryDevices ?? 0,
      activeBonusDevices: data.activeBonusDevices ?? 0,
    },
    devices: devices.map((device) => ({
      installationId: device.installationId,
      platform: device.platform,
      bucket: device.bucket,
      deviceName: device.deviceName ?? null,
      appVersion: device.appVersion ?? null,
      active: device.active,
      activatedAt: timestampMillis(device.activatedAt),
      lastSeenAt: timestampMillis(device.lastSeenAt),
      deactivatedAt: timestampMillis(device.deactivatedAt),
    })),
  };
});

export const activateMyDevice = onCall({region: "us-central1"}, async (req) => {
  const {uid} = requireAuth(req);
  const installationId = String(req.data?.installationId ?? "").trim();
  const platform = String(req.data?.platform ?? "").trim().toLowerCase();
  if (!installationId) {
    throw new HttpsError("invalid-argument", "installationId is required.");
  }
  if (!isDevicePlatform(platform)) {
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
