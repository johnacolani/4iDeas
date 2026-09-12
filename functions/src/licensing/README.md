# 4iCAD production licensing backend

This directory is the trusted server-side foundation for device-based 4iCAD licensing. Production work is isolated on `feature/production-store-verification` until purchase verification, refunds/revocations, device management, and native app integration pass end-to-end tests.

## License policy

- Individual: 1 primary-platform device + 1 device on another platform.
- Company: 10 primary-platform devices + 3 devices on other platforms.
- Web/browser sessions are not device seats in this first phase.
- Device activation/deactivation mutate counters in Firestore transactions so concurrent requests cannot exceed a seat limit.
- Existing active installations are idempotent: reopening the same installation does not consume another seat.
- Website checkout remains limited to Windows, direct-download macOS, and Linux. iOS/Android keep native App Store / Google Play purchase paths.

## Cross-project identity bridge

- `fourICadLicenseBridge` accepts a short-lived Firebase ID token issued by the separate `icad-75d53` 4iCAD project.
- The bridge verifies the token against `icad-75d53`; it never trusts an email or UID sent in the JSON body.
- Existing verified native-store licenses are resolved directly from the 4iCAD UID.
- Website licenses may auto-link only when 4iCAD and 4iDeas accounts have the exact same verified email.
- One 4iCAD account maps to one stored native-license owner. Website reverse links continue to prevent one paid website account being attached to multiple 4iCAD identities.
- All activation still goes through the same transactional seat-limit code.

## Native App Store / Google Play verification

`fourICadVerifyNativePurchase` is the only path that may convert a native store event into a durable cross-platform license.

The endpoint:

1. verifies the caller's short-lived `icad-75d53` Firebase ID token and requires a verified email;
2. requires the exact production Full Access product id `com.johncolani.fouricad.fullaccess`;
3. verifies Apple purchases through App Store Server API, using production first and sandbox only when the transaction is not found in production;
4. verifies Android purchase tokens with Google Play Developer API `purchases.productsv2.getproductpurchasev2`;
5. grants access only for a completed/purchased transaction and rejects revoked Apple transactions;
6. acknowledges a verified Google Play purchase when Play reports it as pending acknowledgement;
7. hashes store purchase evidence before persistence so raw Google purchase tokens are not stored;
8. prevents the same native purchase evidence from being claimed by a second 4iCAD account;
9. reuses an existing active 4iDeas website license when the same verified email already owns one, otherwise creates a native-store-backed Individual license;
10. activates the current installation under the normal server-side seat policy.

The Flutter app does not set Full Access from `verificationData` alone. Purchased/restored events remain locked until this backend returns `verified: true`. An unverified transaction is not completed by the client, allowing store redelivery/recovery after transient backend failures.

## Secrets

Never commit store credentials to GitHub. Configure them in Firebase / Google Secret Manager:

```bash
firebase functions:secrets:set APPLE_IAP_KEY_ID
firebase functions:secrets:set APPLE_IAP_ISSUER_ID
firebase functions:secrets:set APPLE_IAP_PRIVATE_KEY
firebase functions:secrets:set GOOGLE_PLAY_SERVICE_ACCOUNT_JSON
```

Existing Stripe/trial secrets remain separate:

```bash
firebase functions:secrets:set STRIPE_SECRET_KEY
firebase functions:secrets:set STRIPE_WEBHOOK_SECRET
firebase functions:secrets:set WEB_TRIAL_SIGNING_KEY
```

## Collections

- `licenses`: trusted 4iCAD license summaries.
- `license_devices`: installation-level activation records.
- `license_audit`: server-written activation/deactivation and purchase verification audit trail.
- `license_account_links`: 4iCAD UID -> 4iDeas UID website link records.
- `license_account_links_by_website`: reverse 4iDeas UID -> 4iCAD UID records.
- `native_store_purchases`: replay-resistant verified native purchase records; raw Google purchase tokens are not stored.
- `native_store_license_links`: 4iCAD UID -> trusted license owner for store-backed purchases.

## Current integration status

1. Existing Stripe Sandbox fulfillment creates/updates licenses.
2. My License and admin device-management UI exist on this production licensing branch.
3. Cross-project verified identity linking is implemented server-side.
4. App Store / Google Play server verification is implemented on draft 4iDeas PR #7.
5. Latest 4iCAD native integration is implemented on draft 4iCAD PR #26; it is based on the fully tested main baseline rather than the older PR #24 branch.
6. Cloud Functions TypeScript build/tests pass in GitHub CI for the first production-verification revision.
7. Apple/Google production credentials still need to be configured in Secret Manager before deployment.
8. Real App Store sandbox and Google Play license-tester purchase/restore tests remain mandatory before merge.

## Release blockers still open

Do not merge/deploy this as the final commercial release until all items below are closed:

- Configure Apple In-App Purchase API key credentials and Google Play service-account access.
- Deploy `fourICadVerifyNativePurchase` and the updated `fourICadLicenseBridge`.
- Validate new purchase, restore, reinstall, account switching, pending/cancelled purchase, and seat-limit scenarios on real store test environments.
- Add and validate refund/revocation synchronization. Apple App Store Server Notifications V2 (`REFUND`/relevant revocations) and Google Play RTDN / Voided Purchases must deactivate or reconcile the corresponding trusted entitlement.
- Run the 4iCAD Flutter analyze/test suite on the new native-verification branch because the 4iCAD repository currently has no general PR CI workflow.
- Complete legacy entitlement/coupon migration and final Live Stripe/store validation.
