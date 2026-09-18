/** Review status of a caller (consultant) application. */
export const CallerStatus = {
  PENDING_REVIEW: 'PENDING_REVIEW',
  APPROVED: 'APPROVED',
  REJECTED: 'REJECTED',
  SUSPENDED: 'SUSPENDED',
} as const;
export type CallerStatus = (typeof CallerStatus)[keyof typeof CallerStatus];

/**
 * Live availability, kept in Redis (source: heartbeat + call state) and
 * mirrored to PostgreSQL only as a coarse `lastOnlineAt` for analytics.
 */
export const CallerAvailability = {
  OFFLINE: 'OFFLINE',
  ONLINE: 'ONLINE',
  BUSY: 'BUSY',
  /** Online but has switched off incoming requests. */
  DO_NOT_DISTURB: 'DO_NOT_DISTURB',
} as const;
export type CallerAvailability = (typeof CallerAvailability)[keyof typeof CallerAvailability];

export const UserStatus = {
  ACTIVE: 'ACTIVE',
  BLOCKED: 'BLOCKED',
  DELETED: 'DELETED',
} as const;
export type UserStatus = (typeof UserStatus)[keyof typeof UserStatus];

export const Gender = {
  FEMALE: 'FEMALE',
  MALE: 'MALE',
  NON_BINARY: 'NON_BINARY',
  UNDISCLOSED: 'UNDISCLOSED',
} as const;
export type Gender = (typeof Gender)[keyof typeof Gender];

/** Per-minute pricing for one caller, in integer coins. */
export interface CallerRates {
  privateAudioPerMinute: number;
  privateVideoPerMinute: number;
  randomAudioPerMinute: number;
  randomVideoPerMinute: number;
}
