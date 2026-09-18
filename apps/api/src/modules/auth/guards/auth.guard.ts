import { type CanActivate, type ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ErrorCode } from '@bebu/shared';

import { AppException } from '../../../common/errors/app.exception.js';
import type { ContextualRequest } from '../../../common/utils/request-context.js';
import { AuthService } from '../auth.service.js';
import { AUTH_SCOPE_KEY, type AuthScope } from '../decorators/auth-scope.decorator.js';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator.js';

/**
 * Global authentication guard. Runs after {@link TenantGuard}. Attaches a
 * {@link Principal} to the request or rejects with a stable error code.
 */
@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly auth: AuthService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    if (context.getType() !== 'http') return true;
    const targets = [context.getHandler(), context.getClass()];
    if (this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, targets)) return true;

    const req = context.switchToHttp().getRequest<ContextualRequest>();
    const scope = this.reflector.getAllAndOverride<AuthScope>(AUTH_SCOPE_KEY, targets) ?? 'user';
    const identity = await this.auth.verifyBearer(req.headers.authorization);

    if (scope === 'admin') {
      req.principal = await this.auth.resolveAdminPrincipal(identity, req.tenant);
      return true;
    }

    if (!req.tenant) {
      // TenantGuard should have rejected already; defensive.
      throw AppException.badRequest(ErrorCode.TENANT_HEADER_MISSING, 'Tenant context missing');
    }
    req.principal = await this.auth.resolveUserPrincipal(req.tenant, identity);
    return true;
  }
}
