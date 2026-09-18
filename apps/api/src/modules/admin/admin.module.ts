import { Module } from '@nestjs/common';

import { TenantsModule } from '../tenants/tenants.module.js';
import { AdminMeController } from './admin-me.controller.js';
import { AdminTenantsController } from './admin-tenants.controller.js';
import { AuditLogService } from './audit-log.service.js';

/**
 * Admin panel API. Every mutation records an AuditLog row. Later stages add
 * user/caller management, wallet adjustments, payouts, coin packages,
 * moderation queue and analytics endpoints, all gated by @RequirePermissions.
 */
@Module({
  imports: [TenantsModule],
  controllers: [AdminMeController, AdminTenantsController],
  providers: [AuditLogService],
  exports: [AuditLogService],
})
export class AdminModule {}
