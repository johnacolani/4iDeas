export type AppleEntitlementNotificationType =
  | "REFUND"
  | "REVOKE"
  | "REFUND_REVERSED";

export function isAppleEntitlementNotification(
  value: string
): value is AppleEntitlementNotificationType {
  return value === "REFUND" || value === "REVOKE" || value === "REFUND_REVERSED";
}

/**
 * REFUND / REVOKE are only allowed to remove access when the authoritative
 * transaction API also reports revocation. REFUND_REVERSED is itself a signed
 * Apple instruction to restore service; the transaction is still re-queried and
 * identity-checked before this policy is applied.
 */
export function authoritativeActiveForAppleNotification(params: {
  notificationType: AppleEntitlementNotificationType;
  transactionRevoked: boolean;
}): boolean {
  if (params.notificationType === "REFUND_REVERSED") return true;
  return !params.transactionRevoked;
}
