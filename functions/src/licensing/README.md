# 4iCAD licensing backend (development branch)

This directory is the server-side foundation for device-based 4iCAD licensing.
It is intentionally isolated on `feature/licensing-support-production-launch` until the complete purchase, migration, device-management, and app-integration flow is validated.

Current policy:

- Individual: 1 primary-platform device + 1 device on another platform.
- Company: 10 primary-platform devices + 3 devices on other platforms.
- Web/browser sessions are not device seats in this first phase.
- Device activation and deactivation mutate counters in Firestore transactions so concurrent requests cannot exceed a seat limit.
- Existing active installations are idempotent: reopening the same installation does not consume another seat.
- Website checkout remains limited to Windows, direct-download macOS, and Linux. iOS/Android keep their native store purchase paths.

Cross-project identity bridge:

- `fourICadLicenseBridge` accepts a short-lived Firebase ID token issued by the separate `icad-75d53` 4iCAD project.
- The bridge verifies the token against `icad-75d53`; it never trusts an email or UID sent in the JSON body.
- Automatic linking occurs only when the 4iCAD account and 4iDeas account have the exact same verified email.
- One 4iCAD account maps to one 4iDeas account and vice versa. Reverse links prevent the same paid account being attached to multiple 4iCAD identities.
- Existing links revalidate the current 4iDeas verified email on every request, so an email/account change cannot leave a stale entitlement link active.
- The linked 4iDeas UID remains the license owner; activation still goes through the same transactional seat-limit code used by the website.

Collections introduced:

- `licenses`: one 4iCAD license summary per 4iDeas account during phase one.
- `license_devices`: installation-level activation records.
- `license_audit`: server-written activation/deactivation audit trail.
- `license_account_links`: 4iCAD UID -> 4iDeas UID link records.
- `license_account_links_by_website`: reverse 4iDeas UID -> 4iCAD UID records.

Integration status:

1. Stripe Sandbox fulfillment creates/updates licenses.
2. My License and admin device-management UI exist on the 4iDeas licensing branch.
3. Cross-project verified-email identity linking is implemented server-side.
4. Native 4iCAD integration is isolated on draft PR `johnacolani/4iCad#24`; iOS/Android/macOS can present their 4iCAD Firebase token, activate the current device, and accept a linked website license alongside App Store / Play Billing ownership.
5. The bridge function must be deployed and a real Windows-purchase -> iOS activation must pass end-to-end before either draft branch is merged.
6. Legacy entitlement/coupon migration and final Live Stripe/store validation remain release gates.
