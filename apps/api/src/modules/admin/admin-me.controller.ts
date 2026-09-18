import { Controller, Get } from '@nestjs/common';
import type { Permission, Role } from '@bebu/shared';

import { AdminScope } from '../auth/decorators/auth-scope.decorator.js';
import { CurrentPrincipal } from '../auth/decorators/current-principal.decorator.js';
import type { AdminPrincipal } from '../auth/principal.js';

export interface AdminMeView {
  adminId: string;
  tenantId: string | null;
  roles: readonly Role[];
  permissions: readonly Permission[];
  email: string | null;
}

@Controller('admin')
@AdminScope()
export class AdminMeController {
  /** Lets the admin panel learn its role/permissions after Firebase sign-in. */
  @Get('me')
  me(@CurrentPrincipal() principal: AdminPrincipal): AdminMeView {
    return {
      adminId: principal.adminId,
      tenantId: principal.tenantId,
      roles: principal.roles,
      permissions: [...principal.permissions],
      email: principal.identity.email,
    };
  }
}
