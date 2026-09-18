import type { Permission, Role } from '@bebu/shared';

import type { VerifiedIdentity } from '../../infrastructure/firebase/token-verifier.js';

/**
 * The authenticated actor for a request, resolved server-side from a verified
 * identity plus our own database. Handlers never see raw tokens.
 */
export type Principal = UserPrincipal | AdminPrincipal;

export interface UserPrincipal {
  kind: 'user';
  identity: VerifiedIdentity;
  userId: string;
  tenantId: string;
  roles: readonly Role[];
  permissions: ReadonlySet<Permission>;
  /** Present when the user has an APPROVED caller profile. */
  callerProfileId: string | null;
}

export interface AdminPrincipal {
  kind: 'admin';
  identity: VerifiedIdentity;
  adminId: string;
  /** Null for SUPER_ADMIN (platform-wide). */
  tenantId: string | null;
  roles: readonly Role[];
  permissions: ReadonlySet<Permission>;
}

export function isAdminPrincipal(p: Principal): p is AdminPrincipal {
  return p.kind === 'admin';
}

export function isUserPrincipal(p: Principal): p is UserPrincipal {
  return p.kind === 'user';
}
