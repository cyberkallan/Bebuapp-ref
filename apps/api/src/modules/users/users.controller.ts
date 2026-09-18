import { Controller, Get } from '@nestjs/common';

import { CurrentPrincipal } from '../auth/decorators/current-principal.decorator.js';
import type { UserPrincipal } from '../auth/principal.js';
import { type UserProfileView, UsersService } from './users.service.js';

@Controller('users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  /** The signed-in user's own profile. Provisioned on first call. */
  @Get('me')
  async me(@CurrentPrincipal() principal: UserPrincipal): Promise<UserProfileView> {
    const user = await this.users.findOrProvision(principal.tenantId, principal.identity);
    return this.users.toProfileView(user);
  }
}
