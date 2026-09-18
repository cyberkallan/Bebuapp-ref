import { Module } from '@nestjs/common';

import {
  NOTIFICATION_SENDER,
  type NotificationSender,
  type PushMessage,
  type PushSendResult,
} from './notification-sender.interface.js';

/**
 * Push delivery. This stage wires the contract and a no-op sender so the rest
 * of the system can be developed without FCM credentials. A later stage adds:
 *  - FcmNotificationSender (firebase-admin messaging, APNs via FCM)
 *  - NotificationsProcessor on the NOTIFICATIONS queue writing NotificationLog
 *  - device token lifecycle (register/rotate/prune invalid)
 */
class NoopNotificationSender implements NotificationSender {
  send(_message: PushMessage): Promise<PushSendResult> {
    return Promise.resolve({ providerMessageIds: [], invalidTokens: [] });
  }
}

@Module({
  providers: [{ provide: NOTIFICATION_SENDER, useClass: NoopNotificationSender }],
  exports: [NOTIFICATION_SENDER],
})
export class NotificationsModule {}
