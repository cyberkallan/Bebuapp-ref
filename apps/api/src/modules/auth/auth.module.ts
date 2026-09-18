import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard } from '@nestjs/throttler';

import { TenantGuard } from '../tenants/tenant.guard.js';
import { TenantsModule } from '../tenants/tenants.module.js';
import { UsersModule } from '../users/users.module.js';
import { AuthService } from './auth.service.js';
import { AuthGuard } from './guards/auth.guard.js';
import { PermissionsGuard } from './guards/permissions.guard.js';

/**
 * Registers the global guard chain. Order matters:
 *   1. ThrottlerGuard   - reject abusive clients before doing any work
 *   2. TenantGuard      - resolve X-Tenant-Key
 *   3. AuthGuard        - verify token, load principal (scoped by tenant)
 *   4. PermissionsGuard - enforce @RequirePermissions
 */
@Module({
  imports: [TenantsModule, UsersModule],
  providers: [
    AuthService,
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_GUARD, useClass: TenantGuard },
    { provide: APP_GUARD, useClass: AuthGuard },
    { provide: APP_GUARD, useClass: PermissionsGuard },
  ],
  exports: [AuthService],
})
export class AuthModule {}
