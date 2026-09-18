import { Controller, Get } from '@nestjs/common';
import type { TenantPublicConfig } from '@bebu/shared';

import { Public } from '../auth/decorators/public.decorator.js';
import { RequireTenant } from './require-tenant.decorator.js';
import { CurrentTenant, type TenantContext } from './tenant-context.js';
import { TenantsService } from './tenants.service.js';

/**
 * Tenant endpoints for mobile clients. Public because the app needs branding
 * and feature flags before the user signs in; still requires X-Tenant-Key.
 */
@Controller('tenant')
export class TenantsController {
  constructor(private readonly tenants: TenantsService) {}

  @Get('config')
  @Public()
  @RequireTenant()
  getConfig(@CurrentTenant() tenant: TenantContext): Promise<TenantPublicConfig> {
    return this.tenants.getPublicConfig(tenant.id);
  }
}
