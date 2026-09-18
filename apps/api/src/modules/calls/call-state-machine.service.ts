import { Injectable } from '@nestjs/common';
import { type CallState, ErrorCode, canTransitionCall, isTerminalCallState } from '@bebu/shared';

import { AppException } from '../../common/errors/app.exception.js';
import type { DbTransaction } from '../../infrastructure/database/prisma.service.js';
import type { Call } from '../../generated/prisma/client.js';

export interface TransitionActor {
  type: 'USER' | 'ADMIN' | 'SYSTEM';
  id: string | null;
}

export interface TransitionInput {
  callId: string;
  /** Version the caller observed; guards against lost updates. */
  expectedVersion: number;
  to: CallState;
  actor: TransitionActor;
  reason?: string;
  /** Timestamps to stamp on the call for the target state. */
  at?: Date;
}

/**
 * Persists call state transitions atomically:
 *   1. lock the call row, 2. validate the transition against the shared
 *   table, 3. update state + timestamps + version, 4. append an audit row.
 *
 * Only the server calls this. Client events are mapped to transitions by the
 * CallsService (later stage) after participant checks.
 */
@Injectable()
export class CallStateMachineService {
  async transition(tx: DbTransaction, input: TransitionInput): Promise<Call> {
    const [current] = await tx.$queryRaw<{ id: string; state: CallState; stateVersion: number }[]>`
      SELECT id, state, "stateVersion" FROM calls WHERE id = ${input.callId}::uuid FOR UPDATE
    `;
    if (!current) throw AppException.notFound(ErrorCode.CALL_NOT_FOUND, 'Call not found');

    if (current.stateVersion !== input.expectedVersion) {
      throw AppException.conflict(
        ErrorCode.CALL_INVALID_TRANSITION,
        'Call was modified concurrently',
      );
    }
    if (!canTransitionCall(current.state, input.to)) {
      throw AppException.conflict(
        ErrorCode.CALL_INVALID_TRANSITION,
        `Cannot move call from ${current.state} to ${input.to}`,
      );
    }

    const at = input.at ?? new Date();
    const updated = await tx.call.update({
      where: { id: input.callId },
      data: {
        state: input.to,
        stateVersion: { increment: 1 },
        ...this.timestampsFor(input.to, at),
      },
    });

    await tx.callStateTransition.create({
      data: {
        callId: input.callId,
        fromState: current.state,
        toState: input.to,
        actorType: input.actor.type,
        actorId: input.actor.id,
        reason: input.reason ?? null,
        createdAt: at,
      },
    });

    return updated;
  }

  private timestampsFor(
    state: CallState,
    at: Date,
  ): Partial<Pick<Call, 'ringingAt' | 'acceptedAt' | 'connectedAt' | 'endedAt'>> {
    switch (state) {
      case 'RINGING':
        return { ringingAt: at };
      case 'ACCEPTED':
        return { acceptedAt: at };
      case 'CONNECTED':
        return { connectedAt: at };
      default:
        return isTerminalCallState(state) ? { endedAt: at } : {};
    }
  }
}
