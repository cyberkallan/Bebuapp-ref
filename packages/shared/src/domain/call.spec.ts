import { describe, expect, it } from 'vitest';

import {
  ACTIVE_CALL_STATES,
  BILLABLE_CALL_STATES,
  CALL_STATE_TRANSITIONS,
  CallState,
  InvalidCallTransitionError,
  TERMINAL_CALL_STATES,
  assertCallTransition,
  canTransitionCall,
  isTerminalCallState,
} from './call.js';

describe('call state machine', () => {
  it('allows the full happy path', () => {
    const path: CallState[] = [
      CallState.REQUESTED,
      CallState.RINGING,
      CallState.ACCEPTED,
      CallState.CONNECTING,
      CallState.CONNECTED,
      CallState.BILLING,
      CallState.ENDING,
      CallState.COMPLETED,
    ];
    for (let i = 0; i < path.length - 1; i++) {
      expect(canTransitionCall(path[i]!, path[i + 1]!)).toBe(true);
    }
  });

  it('never allows leaving a terminal state', () => {
    for (const terminal of TERMINAL_CALL_STATES) {
      expect(CALL_STATE_TRANSITIONS[terminal]).toHaveLength(0);
      expect(isTerminalCallState(terminal)).toBe(true);
      for (const target of Object.values(CallState)) {
        expect(canTransitionCall(terminal, target)).toBe(false);
      }
    }
  });

  it('rejects skipping straight from REQUESTED to CONNECTED or COMPLETED', () => {
    expect(canTransitionCall(CallState.REQUESTED, CallState.CONNECTED)).toBe(false);
    expect(canTransitionCall(CallState.REQUESTED, CallState.COMPLETED)).toBe(false);
    expect(() => assertCallTransition(CallState.REQUESTED, CallState.COMPLETED)).toThrow(
      InvalidCallTransitionError,
    );
  });

  it('only allows insufficient balance while a charge could happen', () => {
    const allowedSources = Object.entries(CALL_STATE_TRANSITIONS)
      .filter(([, targets]) => targets.includes(CallState.INSUFFICIENT_BALANCE))
      .map(([from]) => from as CallState);
    expect(new Set(allowedSources)).toEqual(
      new Set([CallState.REQUESTED, CallState.CONNECTED, CallState.BILLING]),
    );
  });

  it('every non-terminal state can FAIL', () => {
    for (const state of Object.values(CallState)) {
      if (TERMINAL_CALL_STATES.has(state)) continue;
      expect(canTransitionCall(state, CallState.FAILED)).toBe(true);
    }
  });

  it('every transition target is a known state', () => {
    const known = new Set<string>(Object.values(CallState));
    for (const targets of Object.values(CALL_STATE_TRANSITIONS)) {
      for (const t of targets) expect(known.has(t)).toBe(true);
    }
  });

  it('billable states are a subset of active states', () => {
    for (const s of BILLABLE_CALL_STATES) expect(ACTIVE_CALL_STATES.has(s)).toBe(true);
  });

  it('active and terminal states partition the state space', () => {
    const all = new Set(Object.values(CallState));
    expect(ACTIVE_CALL_STATES.size + TERMINAL_CALL_STATES.size).toBe(all.size);
    for (const s of ACTIVE_CALL_STATES) expect(TERMINAL_CALL_STATES.has(s)).toBe(false);
  });
});
