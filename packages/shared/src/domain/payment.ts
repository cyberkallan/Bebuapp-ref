/**
 * Payment vocabulary. Payments are provider-agnostic: the wallet only ever
 * sees a verified `PaymentOrder`, never a provider payload.
 */
export const PaymentProviderKind = {
  /** Card / UPI / net-banking gateway used on web or via a hosted checkout. */
  WEB: 'WEB',
  GOOGLE_PLAY: 'GOOGLE_PLAY',
  APPLE_IAP: 'APPLE_IAP',
  /** Internal: admin grants, promotions. Never available to clients. */
  MANUAL: 'MANUAL',
} as const;
export type PaymentProviderKind = (typeof PaymentProviderKind)[keyof typeof PaymentProviderKind];

export const PaymentOrderStatus = {
  /** Order created server-side, awaiting the client to pay. */
  CREATED: 'CREATED',
  /** Provider reported payment; awaiting server-side verification. */
  PENDING_VERIFICATION: 'PENDING_VERIFICATION',
  /** Verified with the provider and coins credited (exactly once). */
  COMPLETED: 'COMPLETED',
  FAILED: 'FAILED',
  CANCELLED: 'CANCELLED',
  EXPIRED: 'EXPIRED',
  REFUNDED: 'REFUNDED',
  CHARGED_BACK: 'CHARGED_BACK',
} as const;
export type PaymentOrderStatus = (typeof PaymentOrderStatus)[keyof typeof PaymentOrderStatus];

export const TERMINAL_PAYMENT_STATUSES: ReadonlySet<PaymentOrderStatus> = new Set<PaymentOrderStatus>(
  [
    PaymentOrderStatus.COMPLETED,
    PaymentOrderStatus.FAILED,
    PaymentOrderStatus.CANCELLED,
    PaymentOrderStatus.EXPIRED,
    PaymentOrderStatus.REFUNDED,
    PaymentOrderStatus.CHARGED_BACK,
  ],
);

/** Client platform that initiated a purchase (drives provider selection). */
export const ClientPlatform = {
  ANDROID: 'ANDROID',
  IOS: 'IOS',
  WEB: 'WEB',
} as const;
export type ClientPlatform = (typeof ClientPlatform)[keyof typeof ClientPlatform];

/** Caller cash-out lifecycle. */
export const PayoutStatus = {
  REQUESTED: 'REQUESTED',
  APPROVED: 'APPROVED',
  PAID: 'PAID',
  REJECTED: 'REJECTED',
  FAILED: 'FAILED',
} as const;
export type PayoutStatus = (typeof PayoutStatus)[keyof typeof PayoutStatus];
