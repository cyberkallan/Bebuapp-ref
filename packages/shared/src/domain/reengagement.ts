/**
 * Domain events that may trigger a re-engagement notification.
 * Producers emit these; the re-engagement engine decides (cooldowns, quiet
 * hours, preferences, frequency caps, scoring) whether anything is sent.
 */
export const ReengagementEvent = {
  CALL_ENDED: 'CALL_ENDED',
  CALL_MISSED: 'CALL_MISSED',
  CALLER_ONLINE: 'CALLER_ONLINE',
  PREVIOUS_CALLER_AVAILABLE: 'PREVIOUS_CALLER_AVAILABLE',
  WALLET_LOW: 'WALLET_LOW',
  WALLET_EMPTY: 'WALLET_EMPTY',
  USER_INACTIVE: 'USER_INACTIVE',
} as const;
export type ReengagementEvent = (typeof ReengagementEvent)[keyof typeof ReengagementEvent];

/**
 * Notification categories a user can opt in/out of individually.
 * Every push we send is tagged with exactly one category.
 */
export const NotificationCategory = {
  /** Incoming call / call state. Cannot be disabled while the app is usable. */
  CALL: 'CALL',
  /** Payment receipts, low balance. */
  WALLET: 'WALLET',
  /** Availability of callers the user has interacted with. */
  AVAILABILITY: 'AVAILABILITY',
  /** Offers, bonuses. */
  PROMOTION: 'PROMOTION',
  /** Account security, moderation outcomes. */
  ACCOUNT: 'ACCOUNT',
} as const;
export type NotificationCategory = (typeof NotificationCategory)[keyof typeof NotificationCategory];

/**
 * Sender identity shown on a notification. System-generated messages must be
 * labelled as such: never imply a human personally wrote a message unless the
 * caller actually did.
 */
export const NotificationOrigin = {
  SYSTEM: 'SYSTEM',
  /** Message actually authored by the referenced caller (e.g. chat). */
  CALLER_AUTHORED: 'CALLER_AUTHORED',
} as const;
export type NotificationOrigin = (typeof NotificationOrigin)[keyof typeof NotificationOrigin];

export const NotificationDeliveryStatus = {
  QUEUED: 'QUEUED',
  SENT: 'SENT',
  SUPPRESSED: 'SUPPRESSED',
  FAILED: 'FAILED',
} as const;
export type NotificationDeliveryStatus =
  (typeof NotificationDeliveryStatus)[keyof typeof NotificationDeliveryStatus];

/** Why a notification decision was negative. Persisted for tuning. */
export const SuppressionReason = {
  USER_OPTED_OUT: 'USER_OPTED_OUT',
  QUIET_HOURS: 'QUIET_HOURS',
  COOLDOWN: 'COOLDOWN',
  FREQUENCY_CAP: 'FREQUENCY_CAP',
  LOW_SCORE: 'LOW_SCORE',
  NO_DEVICE_TOKEN: 'NO_DEVICE_TOKEN',
  TENANT_RULE: 'TENANT_RULE',
} as const;
export type SuppressionReason = (typeof SuppressionReason)[keyof typeof SuppressionReason];

export interface QuietHours {
  /** IANA timezone, e.g. "Asia/Kolkata". */
  timezone: string;
  /** 0-23, inclusive start. */
  startHour: number;
  /** 0-23, exclusive end. May be less than startHour to wrap past midnight. */
  endHour: number;
}

export interface NotificationPreferences {
  categories: Record<NotificationCategory, boolean>;
  quietHours: QuietHours | null;
  /** Hard cap of re-engagement pushes per rolling 24h. */
  maxReengagementPerDay: number;
}

export const DEFAULT_NOTIFICATION_PREFERENCES: NotificationPreferences = {
  categories: {
    CALL: true,
    WALLET: true,
    AVAILABILITY: true,
    PROMOTION: false,
    ACCOUNT: true,
  },
  quietHours: null,
  maxReengagementPerDay: 3,
};
