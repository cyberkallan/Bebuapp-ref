import { SetMetadata } from '@nestjs/common';

export const AUTH_SCOPE_KEY = 'auth:scope';

/**
 * Which kind of account a route serves.
 * - user  (default): end users of a branded app; requires X-Tenant-Key.
 * - admin: staff accounts from the admin panel; tenant header optional
 *          (required for tenant-scoped admins when acting on tenant data).
 */
export type AuthScope = 'user' | 'admin';

export const AuthScopeMeta = (scope: AuthScope) => SetMetadata(AUTH_SCOPE_KEY, scope);

/** Shorthand for controllers that only serve admin accounts. */
export const AdminScope = () => AuthScopeMeta('admin');
