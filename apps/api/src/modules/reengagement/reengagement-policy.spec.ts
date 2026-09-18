import { DEFAULT_NOTIFICATION_PREFERENCES, type NotificationPreferences, SuppressionReason } from '@bebu/shared';

import { evaluateReengagement, isInQuietHours, type PolicyInput } from './reengagement-policy.js';

const prefs = (overrides: Partial<NotificationPreferences> = {}): NotificationPreferences => ({
  ...DEFAULT_NOTIFICATION_PREFERENCES,
  ...overrides,
  categories: { ...DEFAULT_NOTIFICATION_PREFERENCES.categories, ...(overrides.categories ?? {}) },
});

const input = (overrides: Partial<PolicyInput> = {}): PolicyInput => ({
  event: 'CALLER_ONLINE',
  preferences: prefs(),
  now: new Date('2026-09-18T12:00:00Z'),
  lastSentAt: null,
  sentLast24h: 0,
  hasDeviceToken: true,
  tenantAllowsEvent: true,
  ...overrides,
});

describe('quiet hours', () => {
  it('evaluates in the user timezone and supports wrap-around windows', () => {
    // 22:00 -> 07:00 Asia/Kolkata (UTC+5:30). 12:00Z = 17:30 IST -> outside.
    const quiet = { timezone: 'Asia/Kolkata', startHour: 22, endHour: 7 };
    expect(isInQuietHours(quiet, new Date('2026-09-18T12:00:00Z'))).toBe(false);
    // 18:00Z = 23:30 IST -> inside.
    expect(isInQuietHours(quiet, new Date('2026-09-18T18:00:00Z'))).toBe(true);
    // 00:30Z = 06:00 IST -> inside (wrapped).
    expect(isInQuietHours(quiet, new Date('2026-09-18T00:30:00Z'))).toBe(true);
    // 02:00Z = 07:30 IST -> outside.
    expect(isInQuietHours(quiet, new Date('2026-09-18T02:00:00Z'))).toBe(false);
  });

  it('treats an empty window as disabled', () => {
    expect(isInQuietHours({ timezone: 'UTC', startHour: 9, endHour: 9 }, new Date())).toBe(false);
    expect(isInQuietHours(null, new Date())).toBe(false);
  });
});

describe('evaluateReengagement', () => {
  it('allows a first availability push with defaults', () => {
    expect(evaluateReengagement(input())).toEqual({ allow: true, category: 'AVAILABILITY' });
  });

  it('applies rules in priority order and reports the first failure', () => {
    expect(evaluateReengagement(input({ tenantAllowsEvent: false }))).toMatchObject({
      allow: false,
      reason: SuppressionReason.TENANT_RULE,
    });
    expect(evaluateReengagement(input({ hasDeviceToken: false }))).toMatchObject({
      reason: SuppressionReason.NO_DEVICE_TOKEN,
    });
    expect(
      evaluateReengagement(input({ preferences: prefs({ categories: { AVAILABILITY: false } as never }) })),
    ).toMatchObject({ reason: SuppressionReason.USER_OPTED_OUT });
    expect(
      evaluateReengagement(
        input({
          preferences: prefs({ quietHours: { timezone: 'UTC', startHour: 11, endHour: 13 } }),
        }),
      ),
    ).toMatchObject({ reason: SuppressionReason.QUIET_HOURS });
  });

  it('enforces per-event cooldowns', () => {
    const now = new Date('2026-09-18T12:00:00Z');
    const oneHourAgo = new Date(now.getTime() - 3600 * 1000);
    const fiveHoursAgo = new Date(now.getTime() - 5 * 3600 * 1000);
    expect(evaluateReengagement(input({ now, lastSentAt: oneHourAgo }))).toMatchObject({
      reason: SuppressionReason.COOLDOWN,
    });
    expect(evaluateReengagement(input({ now, lastSentAt: fiveHoursAgo })).allow).toBe(true);
    expect(
      evaluateReengagement(input({ now, lastSentAt: oneHourAgo, cooldownSecondsOverride: 60 })).allow,
    ).toBe(true);
  });

  it('enforces the daily frequency cap', () => {
    expect(evaluateReengagement(input({ sentLast24h: 3 }))).toMatchObject({
      reason: SuppressionReason.FREQUENCY_CAP,
    });
    expect(evaluateReengagement(input({ sentLast24h: 2 })).allow).toBe(true);
  });

  it('promotional events default to opted-out', () => {
    expect(evaluateReengagement(input({ event: 'USER_INACTIVE' }))).toMatchObject({
      reason: SuppressionReason.USER_OPTED_OUT,
      category: 'PROMOTION',
    });
  });
});
