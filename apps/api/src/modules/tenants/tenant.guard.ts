import { type CanActivate, type ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ErrorCode, TENANT_HEADER, TenantStatus, tenantKeySchema } from '@bebu/shared';

import { AppException } from '../../common/errors/app.exception.js';
import type { ContextualRequest } from '../../common/utils/request-context.js';
import { AUTH_SCOPE_KEY, type AuthScope } from '../auth/decorators/auth-scope.decorator.js';
import { IS_PUBLIC_KEY } from '../auth/decorators/public.decorator.js';
import { REQUIRE_TENANT_KEY } from './require-tenant.decorator.js';
import { TenantsService } from './tenants.service.js';

/**
 * Resolves X-Tenant-Key into a {@link TenantContext} on the request. Runs
 * before authentication so the auth layer can scope user lookups by tenant.
 *
 * - user scope (default): header REQUIRED unless the route is @Public.
 * - admin scope / public: header OPTIONAL; resolved when present.
 * - A suspended/archived tenant blocks user traffic but stays visible to admins.
 */
@Injectable()
export class TenantGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly tenants: TenantsService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    if (context.getType() !== 'http') return true;
    const req = context.switchToHttp().getRequest<ContextualRequest>();
    const targets = [context.getHandler(), context.getClass()];

    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, targets) ?? false;
    const scope = this.reflector.getAllAndOverride<AuthScope>(AUTH_SCOPE_KEY, targets) ?? 'user';
    const forced = this.reflector.getAllAndOverride<boolean>(REQUIRE_TENANT_KEY, targets) ?? false;
    const required = forced || (scope === 'user' && !isPublic);

    const raw = req.headers[TENANT_HEADER];
    const headerValue = Array.isArray(raw) ? raw[0] : raw;

    if (!headerValue) {
      if (required) {
        throw AppException.badRequest(
          ErrorCode.TENANT_HEADER_MISSING,
          `Missing ${TENANT_HEADER} header`,
        );
      }
      return true;
    }

    const parsed = tenantKeySchema.safeParse(headerValue);
    if (!parsed.success) {
      throw AppException.badRequest(ErrorCode.TENANT_NOT_FOUND, 'Malformed tenant key');
    }

    const tenant = await this.tenants.resolveContextByKey(parsed.data);
    if (!tenant) throw AppException.notFound(ErrorCode.TENANT_NOT_FOUND, 'Unknown tenant');

    if (scope === 'user' && tenant.status !== TenantStatus.ACTIVE) {
      throw AppException.forbidden(
        ErrorCode.TENANT_SUSPENDED,
        'This application is currently unavailable',
      );
    }

    req.tenant = tenant;
    return true;
  }
}
