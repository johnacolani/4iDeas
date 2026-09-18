/**
 * Test-store licenses must never shadow a verified production or complimentary
 * license. These sources can only exist for isolated sandbox/license testing.
 */
export function isTestStoreLicenseSource(source: unknown): boolean {
  return source === "app_store_test" || source === "google_play_test";
}
