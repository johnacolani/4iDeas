# 4iCAD licensing backend (development branch)

This directory is the server-side foundation for device-based 4iCAD licensing.
It is intentionally isolated on `feature/licensing-support-production-launch` until the complete purchase, migration, device-management, and app-integration flow is validated.

Current policy:

- Individual: 1 primary-platform device + 1 device on another platform.
- Company: 10 primary-platform devices + 3 devices on other platforms.
- Web/browser sessions are not device seats in this first phase.
- Device activation and deactivation mutate counters in Firestore transactions so concurrent requests cannot exceed a seat limit.
- Existing active installations are idempotent: reopening the same installation does not consume another seat.
- No current production customer is blocked by this code yet; 4iCAD has not been wired to these callables.

Collections introduced:

- `licenses`: one 4iCAD license summary per 4ideas account during phase one.
- `license_devices`: installation-level activation records.
- `license_audit`: server-written activation/deactivation audit trail.

Next phases:

1. Wire Stripe Sandbox fulfillment to create/update licenses.
2. Add My License and admin device-management UI.
3. Add secure identity/linking between the separate 4ideas and 4iCAD Firebase projects.
4. Integrate 4iCAD in monitor-only mode before enabling enforcement.
5. Migrate legacy entitlements/coupons before any hard blocking.
6. Switch Stripe secrets/prices/webhook to Live only after end-to-end production verification.
