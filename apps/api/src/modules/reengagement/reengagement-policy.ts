import {
  NotificationCategory,
  type NotificationPreferences,
  type QuietHours,
  type ReengagementEvent,
  SuppressionReason,
} from '@bebu/shared';

/** Which notification category each re-engagement event belongs to. */
export const EVENT_CATEGORY: Readonly<Record<ReengagementEvent, NotificationCategory>> = {
  CALL_ENDED: NotificationCategory.PROMOTION,
  CALL_MISSED: NotificationCategory.CALL,
  CALLER_ONLINE: NotificationCategory.AVAILABILITY,
  PREVIOUS_CALLER_AVAILABLE: NotificationCategory.AVAILABILITY,
  WALLET_LOW: NotificationCategory.WALLET,
  WALLET_EMPTY: NotificationCategory.WALLET,
  USER_INACTIVE: NotificationCategory.PROMOTION,
};

/** Minimum seconds between two pushes for the same (user, event). */
export const DEFAULT_EVENT_COOLDOWN_SECONDS: Readonly<Record<ReengagementEvent, number>> = {
  CALL_ENDED: 6 * 3600,
  CALL_MISSED: 0,
  CALLER_ONLINE: 4 * 3600,
  PREVIOUS_CALLER_AVAILABLE: 12 * 3600,
  WALLET_LOW: 24 * 3600,
  WALLET_EMPTY: 24 * 3600,
  USER_INACTIVE: 72 * 3600,
};

export interface PolicyInput {
  event: ReengagementEvent;
  preferences: NotificationPreferences;
  /** Wall-clock instant of the decision. */
  now: Date;
  /** Last time this (user, event) was sent, if ever. */
  lastSentAt: Date | null;
  /** Re-engagement pushes sent to the user in the trailing 24h. */
  sentLast24h: number;
  hasDeviceToken: boolean;
  /** Tenant override for cooldowns (seconds); falls back to defaults. */
  cooldownSecondsOverride?: number;
  /** Tenant-level kill switch for this event. */
  tenantAllowsEvent: boolean;
}

export type PolicyDecision =
  | { allow: true; category: NotificationCategory }
  | { allow: false; reason: SuppressionReason; category: NotificationCategory };

/**
 * Returns true when `now` falls inside the user's quiet hours, evaluated in
 * the user's timezone. Windows may wrap past midnight (e.g. 22 -> 7).
 */
export function isInQuietHours(quiet: QuietHours | null, now: Date): boolean {
  if (!quiet) return false;
  const hour = Number(
    new Intl.DateTimeFormat('en-US', { hour: 'numeric', hour12: false, timeZone: quiet.timezone }).format(now),
  );
  const h = hour === 24 ? 0 : hour;
  const { startHour, endHour } = quiet;
  if (startHour === endHour) return false;
  return startHour < endHour ? h >= startHour && h < endHour : h >= startHour || h < endHour;
}

/**
 * Pure decision function. Incoming CALL notifications bypass re-engagement
 * rules entirely and never go through here. Everything else must pass every
 * rule, in this order, and the first failing rule is recorded for tuning.
 */
export function evaluateReengagement(input: PolicyInput): PolicyDecision {
  const category = EVENT_CATEGORY[input.event];
  const deny = (reason: SuppressionReason): PolicyDecision => ({ allow: false, reason, category });

  if (!input.tenantAllowsEvent) return deny(SuppressionReason.TENANT_RULE);
  if (!input.hasDeviceToken) return deny(SuppressionReason.NO_DEVICE_TOKEN);
  if (!input.preferences.categories[category]) return deny(SuppressionReason.USER_OPTED_OUT);
  if (isInQuietHours(input.preferences.quietHours, input.now)) return deny(SuppressionReason.QUIET_HOURS);

  const cooldown = input.cooldownSecondsOverride ?? DEFAULT_EVENT_COOLDOWN_SECONDS[input.event] ?? 0;
  if (input.lastSentAt && input.now.getTime() - input.lastSentAt.getTime() < cooldown * 1000) {
    return deny(SuppressionReason.COOLDOWN);
  }
  if (input.sentLast24h >= input.preferences.maxReengagementPerDay) {
    return deny(SuppressionReason.FREQUENCY_CAP);
  }
  return { allow: true, category };
}
