import { Module } from '@nestjs/common';

import { AgoraModule } from '../agora/agora.module.js';
import { CallersModule } from '../callers/callers.module.js';
import { WalletModule } from '../wallet/wallet.module.js';
import { CallStateMachineService } from './call-state-machine.service.js';

/**
 * Call lifecycle. This stage ships the persistence-level state machine only.
 * Later stages add:
 *  - CallsService: request/accept/reject/hang-up mapping client events to
 *    transitions, balance pre-checks (minimumBalanceToCall), Agora channel +
 *    token issuance, Redis active-call state and presence updates.
 *  - CallLifecycleProcessor (BullMQ CALL_LIFECYCLE queue): ring/connect
 *    timeouts and per-interval billing ticks that debit the user wallet,
 *    credit caller earnings and platform commission in ONE financial
 *    transaction per interval, ending the call on INSUFFICIENT_BALANCE.
 *  - Realtime signalling (WebSocket gateway) for ringing/accept events.
 */
@Module({
  imports: [WalletModule, CallersModule, AgoraModule],
  providers: [CallStateMachineService],
  exports: [CallStateMachineService],
})
export class CallsModule {}
