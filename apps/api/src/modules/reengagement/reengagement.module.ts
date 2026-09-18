import { Module } from '@nestjs/common';

import { NotificationsModule } from '../notifications/notifications.module.js';

/**
 * Event-driven re-engagement. This stage ships the pure policy
 * (`reengagement-policy.ts`: opt-outs, quiet hours, cooldowns, frequency
 * caps, tenant rules). A later stage adds:
 *  - ReengagementEventBus: domain modules emit ReengagementEvent jobs on the
 *    REENGAGEMENT queue (call ended/missed, caller online, wallet low/empty,
 *    inactivity sweeps).
 *  - ReengagementProcessor: loads preferences + NotificationLog history,
 *    runs evaluateReengagement, scores candidates, renders a template and
 *    enqueues a PushMessage with origin=SYSTEM. Copy must never imply a caller
 *    personally wrote a message they did not.
 */
@Module({
  imports: [NotificationsModule],
})
export class ReengagementModule {}
