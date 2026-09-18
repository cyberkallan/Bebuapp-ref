import { type CanActivate, type ExecutionContext, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ErrorCode, type Permission } from '@bebu/shared';

import { AppException } from '../../../common/errors/app.exception.js';
import type { ContextualRequest } from '../../../common/utils/request-context.js';
import { PERMISSIONS_KEY } from '../decorators/permissions.decorator.js';

/**
 * Enforces `@RequirePermissions(...)`. Permissions derive from roles stored
 * in PostgreSQL (see AuthService), so this guard is purely a lookup.
 */
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    if (context.getType() !== 'http') return true;
    const required =
      this.reflector.getAllAndOverride<readonly Permission[]>(PERMISSIONS_KEY, [
        context.getHandler(),
        context.getClass(),
      ]) ?? [];
    if (required.length === 0) return true;

    const principal = context.switchToHttp().getRequest<ContextualRequest>().principal;
    if (!principal) throw AppException.unauthorized();

    const missing = required.filter((p) => !principal.permissions.has(p));
    if (missing.length > 0) {
      throw AppException.forbidden(ErrorCode.FORBIDDEN, 'Insufficient permissions');
    }
    return true;
  }
}
