import { z } from 'zod';

import { CallEndReason, CallMode, CallState, CallType } from '../domain/call.js';
import { idSchema, idempotencyKeySchema } from './common.js';

export const requestCallSchema = z.object({
  callerId: idSchema,
  type: z.enum(CallType),
  mode: z.enum(CallMode).default('PRIVATE'),
  idempotencyKey: idempotencyKeySchema,
});
export type RequestCallInput = z.infer<typeof requestCallSchema>;

/**
 * Events the mobile client is allowed to REPORT. The server maps them to
 * state transitions after validating the reporter is a participant and the
 * transition is legal. Note the absence of any "charge" or "duration" event.
 */
export const CallClientEvent = {
  RINGING_STARTED: 'RINGING_STARTED',
  ACCEPTED: 'ACCEPTED',
  REJECTED: 'REJECTED',
  CANCELLED: 'CANCELLED',
  MEDIA_CONNECTED: 'MEDIA_CONNECTED',
  HANG_UP: 'HANG_UP',
  MEDIA_FAILED: 'MEDIA_FAILED',
} as const;
export type CallClientEvent = (typeof CallClientEvent)[keyof typeof CallClientEvent];

export const reportCallEventSchema = z.object({
  callId: idSchema,
  event: z.enum(CallClientEvent),
  /** Client wall-clock for diagnostics only; the server uses its own clock. */
  clientTimestamp: z.iso.datetime().optional(),
});
export type ReportCallEventInput = z.infer<typeof reportCallEventSchema>;

/** Call as seen by a participant. Charges are server-computed. */
export const callViewSchema = z.object({
  id: idSchema,
  type: z.enum(CallType),
  mode: z.enum(CallMode),
  state: z.enum(CallState),
  endReason: z.enum(CallEndReason).nullable(),
  userId: idSchema,
  callerId: idSchema,
  ratePerMinute: z.number().int().nonnegative(),
  requestedAt: z.iso.datetime(),
  connectedAt: z.iso.datetime().nullable(),
  endedAt: z.iso.datetime().nullable(),
  billedSeconds: z.number().int().nonnegative(),
  totalCharged: z.number().int().nonnegative(),
});
export type CallView = z.infer<typeof callViewSchema>;

/** Credentials to join the Agora channel. Contains a short-lived token only. */
export const rtcCredentialsSchema = z.object({
  appId: z.string(),
  channelName: z.string(),
  uid: z.number().int().nonnegative(),
  token: z.string(),
  expiresAt: z.iso.datetime(),
});
export type RtcCredentials = z.infer<typeof rtcCredentialsSchema>;
