import { Module } from '@nestjs/common';

/**
 * Reporting and moderation. Data model (Report, ModerationAction) is in
 * place; endpoints arrive in a later stage:
 *  - POST /reports (user files a report against a participant of a call)
 *  - admin queue: list/open/resolve with mandatory resolution note, each
 *    action mirrored into AuditLog and, when blocking, into User.status.
 */
@Module({})
export class ModerationModule {}
