import type { NotificationCategory, NotificationOrigin } from '@bebu/shared';

/**
 * A rendered push message. `origin` is mandatory so templates cannot forget
 * to label system-generated messages; the sender surfaces it in the payload.
 */
export interface PushMessage {
  tenantId: string;
  userId: string;
  deviceTokens: readonly string[];
  category: NotificationCategory;
  origin: NotificationOrigin;
  templateKey: string;
  title: string;
  body: string;
  /** String-only data payload for deep links; no secrets, no PII beyond ids. */
  data: Readonly<Record<string, string>>;
  /** Time-to-live for the push; incoming-call pushes should be short. */
  ttlSeconds: number;
  collapseKey?: string;
}

export interface PushSendResult {
  providerMessageIds: readonly string[];
  /** Tokens the provider reported as permanently invalid (to be deleted). */
  invalidTokens: readonly string[];
}

export interface NotificationSender {
  send(message: PushMessage): Promise<PushSendResult>;
}

export const NOTIFICATION_SENDER = Symbol('NOTIFICATION_SENDER');
