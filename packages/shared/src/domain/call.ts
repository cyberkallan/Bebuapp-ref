/** Media type of a call. */
export const CallType = {
  AUDIO: 'AUDIO',
  VIDEO: 'VIDEO',
} as const;
export type CallType = (typeof CallType)[keyof typeof CallType];

/** How the two parties were connected. */
export const CallMode = {
  /** User explicitly chose a caller from discovery. */
  PRIVATE: 'PRIVATE',
  /** Platform matched the user with an available caller. */
  RANDOM: 'RANDOM',
} as const;
export type CallMode = (typeof CallMode)[keyof typeof CallMode];

/**
 * Server-authoritative call lifecycle.
 *
 * Happy path:
 *   REQUESTED -> RINGING -> ACCEPTED -> CONNECTING -> CONNECTED -> BILLING -> ENDING -> COMPLETED
 *
 * Failure/terminal states can be reached from the states listed in
 * {@link CALL_STATE_TRANSITIONS}. The mobile client never sets state directly;
 * it reports events and the backend decides the transition.
 */
export const CallState = {
  REQUESTED: 'REQUESTED',
  RINGING: 'RINGING',
  ACCEPTED: 'ACCEPTED',
  CONNECTING: 'CONNECTING',
  CONNECTED: 'CONNECTED',
  BILLING: 'BILLING',
  ENDING: 'ENDING',
  COMPLETED: 'COMPLETED',
  REJECTED: 'REJECTED',
  MISSED: 'MISSED',
  CANCELLED: 'CANCELLED',
  FAILED: 'FAILED',
  INSUFFICIENT_BALANCE: 'INSUFFICIENT_BALANCE',
  TIMEOUT: 'TIMEOUT',
} as const;
export type CallState = (typeof CallState)[keyof typeof CallState];

export const TERMINAL_CALL_STATES: ReadonlySet<CallState> = new Set<CallState>([
  CallState.COMPLETED,
  CallState.REJECTED,
  CallState.MISSED,
  CallState.CANCELLED,
  CallState.FAILED,
  CallState.INSUFFICIENT_BALANCE,
  CallState.TIMEOUT,
]);

/** States during which the callee is considered busy. */
export const ACTIVE_CALL_STATES: ReadonlySet<CallState> = new Set<CallState>([
  CallState.REQUESTED,
  CallState.RINGING,
  CallState.ACCEPTED,
  CallState.CONNECTING,
  CallState.CONNECTED,
  CallState.BILLING,
  CallState.ENDING,
]);

/** States in which per-interval charges may be applied. */
export const BILLABLE_CALL_STATES: ReadonlySet<CallState> = new Set<CallState>([
  CallState.CONNECTED,
  CallState.BILLING,
]);

/**
 * Allowed transitions. Anything not listed is rejected by the state machine.
 * FAILED is reachable from every non-terminal state (infrastructure errors).
 */
export const CALL_STATE_TRANSITIONS: Readonly<Record<CallState, readonly CallState[]>> = {
  REQUESTED: [
    CallState.RINGING,
    CallState.CANCELLED,
    CallState.INSUFFICIENT_BALANCE,
    CallState.TIMEOUT,
    CallState.FAILED,
  ],
  RINGING: [
    CallState.ACCEPTED,
    CallState.REJECTED,
    CallState.MISSED,
    CallState.CANCELLED,
    CallState.TIMEOUT,
    CallState.FAILED,
  ],
  ACCEPTED: [CallState.CONNECTING, CallState.CANCELLED, CallState.TIMEOUT, CallState.FAILED],
  CONNECTING: [CallState.CONNECTED, CallState.ENDING, CallState.TIMEOUT, CallState.FAILED],
  CONNECTED: [
    CallState.BILLING,
    CallState.ENDING,
    CallState.INSUFFICIENT_BALANCE,
    CallState.FAILED,
  ],
  BILLING: [
    CallState.CONNECTED,
    CallState.ENDING,
    CallState.INSUFFICIENT_BALANCE,
    CallState.FAILED,
  ],
  ENDING: [CallState.COMPLETED, CallState.FAILED],
  COMPLETED: [],
  REJECTED: [],
  MISSED: [],
  CANCELLED: [],
  FAILED: [],
  INSUFFICIENT_BALANCE: [],
  TIMEOUT: [],
};

export function isTerminalCallState(state: CallState): boolean {
  return TERMINAL_CALL_STATES.has(state);
}

export function canTransitionCall(from: CallState, to: CallState): boolean {
  return CALL_STATE_TRANSITIONS[from].includes(to);
}

export class InvalidCallTransitionError extends Error {
  constructor(
    public readonly from: CallState,
    public readonly to: CallState,
  ) {
    super(`Invalid call state transition ${from} -> ${to}`);
    this.name = 'InvalidCallTransitionError';
  }
}

/** Returns `to` if the transition is legal, otherwise throws. */
export function assertCallTransition(from: CallState, to: CallState): CallState {
  if (!canTransitionCall(from, to)) throw new InvalidCallTransitionError(from, to);
  return to;
}

/** Why a call reached a terminal state. Stored on the call for analytics. */
export const CallEndReason = {
  CALLER_HUNG_UP: 'CALLER_HUNG_UP',
  CALLEE_HUNG_UP: 'CALLEE_HUNG_UP',
  INSUFFICIENT_BALANCE: 'INSUFFICIENT_BALANCE',
  NETWORK_LOST: 'NETWORK_LOST',
  RING_TIMEOUT: 'RING_TIMEOUT',
  CONNECT_TIMEOUT: 'CONNECT_TIMEOUT',
  REJECTED: 'REJECTED',
  CANCELLED: 'CANCELLED',
  MODERATION: 'MODERATION',
  SERVER_ERROR: 'SERVER_ERROR',
} as const;
export type CallEndReason = (typeof CallEndReason)[keyof typeof CallEndReason];

/** Default lifecycle timeouts (seconds). Tenants may override within bounds. */
export const CALL_TIMEOUTS = {
  ringSeconds: 45,
  connectSeconds: 30,
  /** Billing granularity: users are charged per started interval. */
  billingIntervalSeconds: 60,
  /** How often the server re-checks balance during a connected call. */
  balanceCheckSeconds: 10,
} as const;
