/**
 * Platform roles. Authorization is always evaluated server-side.
 *
 * - SUPER_ADMIN   platform operator; may act on every tenant.
 * - TENANT_ADMIN  full control of exactly one tenant.
 * - TENANT_STAFF  read + moderation within one tenant, no financial config.
 * - CALLER        consultant/caller account (a user with an approved caller profile).
 * - USER          regular end user.
 */
export const Role = {
  SUPER_ADMIN: 'SUPER_ADMIN',
  TENANT_ADMIN: 'TENANT_ADMIN',
  TENANT_STAFF: 'TENANT_STAFF',
  CALLER: 'CALLER',
  USER: 'USER',
} as const;
export type Role = (typeof Role)[keyof typeof Role];

export const ALL_ROLES: readonly Role[] = Object.values(Role);

/** Roles that may use the admin panel. */
export const ADMIN_ROLES: readonly Role[] = [
  Role.SUPER_ADMIN,
  Role.TENANT_ADMIN,
  Role.TENANT_STAFF,
];

/** Roles that are scoped to a single tenant (everything except SUPER_ADMIN). */
export const TENANT_SCOPED_ROLES: readonly Role[] = [
  Role.TENANT_ADMIN,
  Role.TENANT_STAFF,
  Role.CALLER,
  Role.USER,
];

/**
 * Fine-grained permissions. Roles map to permission sets; guards check
 * permissions, not roles, so new roles can be added without touching handlers.
 */
export const Permission = {
  TENANT_READ: 'tenant:read',
  TENANT_WRITE: 'tenant:write',
  TENANT_CREATE: 'tenant:create',
  USER_READ: 'user:read',
  USER_WRITE: 'user:write',
  USER_BLOCK: 'user:block',
  CALLER_READ: 'caller:read',
  CALLER_APPROVE: 'caller:approve',
  CALLER_WRITE: 'caller:write',
  WALLET_READ: 'wallet:read',
  WALLET_ADJUST: 'wallet:adjust',
  PAYMENT_READ: 'payment:read',
  PAYMENT_REFUND: 'payment:refund',
  PAYOUT_APPROVE: 'payout:approve',
  CALL_READ: 'call:read',
  MODERATION_READ: 'moderation:read',
  MODERATION_ACT: 'moderation:act',
  ANALYTICS_READ: 'analytics:read',
  AUDIT_READ: 'audit:read',
  NOTIFICATION_SEND: 'notification:send',
  PLATFORM_SETTINGS: 'platform:settings',
} as const;
export type Permission = (typeof Permission)[keyof typeof Permission];

const TENANT_STAFF_PERMISSIONS: readonly Permission[] = [
  Permission.TENANT_READ,
  Permission.USER_READ,
  Permission.USER_BLOCK,
  Permission.CALLER_READ,
  Permission.WALLET_READ,
  Permission.PAYMENT_READ,
  Permission.CALL_READ,
  Permission.MODERATION_READ,
  Permission.MODERATION_ACT,
  Permission.ANALYTICS_READ,
];

const TENANT_ADMIN_PERMISSIONS: readonly Permission[] = [
  ...TENANT_STAFF_PERMISSIONS,
  Permission.TENANT_WRITE,
  Permission.USER_WRITE,
  Permission.CALLER_APPROVE,
  Permission.CALLER_WRITE,
  Permission.WALLET_ADJUST,
  Permission.PAYMENT_REFUND,
  Permission.PAYOUT_APPROVE,
  Permission.AUDIT_READ,
  Permission.NOTIFICATION_SEND,
];

export const ROLE_PERMISSIONS: Record<Role, readonly Permission[]> = {
  SUPER_ADMIN: Object.values(Permission),
  TENANT_ADMIN: TENANT_ADMIN_PERMISSIONS,
  TENANT_STAFF: TENANT_STAFF_PERMISSIONS,
  CALLER: [],
  USER: [],
};

export function permissionsForRoles(roles: readonly Role[]): ReadonlySet<Permission> {
  const set = new Set<Permission>();
  for (const role of roles) {
    for (const permission of ROLE_PERMISSIONS[role]) set.add(permission);
  }
  return set;
}

export function hasPermission(roles: readonly Role[], permission: Permission): boolean {
  return permissionsForRoles(roles).has(permission);
}
