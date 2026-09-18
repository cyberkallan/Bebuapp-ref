import { createParamDecorator, type ExecutionContext } from '@nestjs/common';
import type { TenantFeatureFlag, TenantStatus } from '@bebu/shared';

import type { ContextualRequest } from '../../common/utils/request-context.js';

/**
 * Minimal tenant data attached to every tenant-scoped request. Resolved from
 * X-Tenant-Key by {@link TenantGuard}; cached in Redis.
 */
export interface TenantContext {
  id: string;
  key: string;
  name: string;
  status: TenantStatus;
  featureFlags: Readonly<Record<TenantFeatureFlag, boolean>>;
}

/** Injects the resolved {@link TenantContext}. Only valid on tenant-scoped routes. */
export const CurrentTenant = createParamDecorator((_data: unknown, ctx: ExecutionContext): TenantContext => {
  const req = ctx.switchToHttp().getRequest<ContextualRequest>();
  if (!req.tenant) throw new Error('CurrentTenant used on a route without tenant resolution');
  return req.tenant;
});
