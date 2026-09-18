/**
 * Names of every BullMQ queue. Register new queues here so workers, producers
 * and dashboards agree on names. Each queue has a single responsibility.
 */
export const QueueName = {
  /** Push notification delivery (FCM/APNs). */
  NOTIFICATIONS: 'notifications',
  /** Re-engagement decisions triggered by domain events. */
  REENGAGEMENT: 'reengagement',
  /** Call lifecycle timers: ring timeout, connect timeout, billing ticks. */
  CALL_LIFECYCLE: 'call-lifecycle',
  /** Payment verification and provider webhook processing. */
  PAYMENTS: 'payments',
  /** Aggregations and metrics rollups. */
  ANALYTICS: 'analytics',
} as const;
export type QueueName = (typeof QueueName)[keyof typeof QueueName];

/** Default job options shared by all queues. */
export const DEFAULT_JOB_OPTIONS = {
  attempts: 5,
  backoff: { type: 'exponential', delay: 2_000 },
  removeOnComplete: { age: 24 * 3600, count: 10_000 },
  removeOnFail: { age: 7 * 24 * 3600 },
} as const;
