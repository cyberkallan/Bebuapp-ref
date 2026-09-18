import { SetMetadata } from '@nestjs/common';
import type { Permission } from '@bebu/shared';

export const PERMISSIONS_KEY = 'auth:permissions';

/** Handler requires ALL listed permissions (evaluated from the principal's roles). */
export const RequirePermissions = (...permissions: readonly Permission[]) =>
  SetMetadata(PERMISSIONS_KEY, permissions);
