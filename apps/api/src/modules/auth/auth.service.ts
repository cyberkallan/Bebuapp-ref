import { Inject, Injectable } from '@nestjs/common';
import { ErrorCode, Role, permissionsForRoles } from '@bebu/shared';

import { AppException } from '../../common/errors/app.exception.js';
import { PrismaService } from '../../infrastructure/database/prisma.service.js';
import {
  TOKEN_VERIFIER,
  TokenVerificationError,
  type TokenVerifier,
  type VerifiedIdentity,
} from '../../infrastructure/firebase/token-verifier.js';
import type { TenantContext } from '../tenants/tenant-context.js';
import { UsersService } from '../users/users.service.js';
import type { AdminPrincipal, UserPrincipal } from './principal.js';

/**
 * Turns a bearer token into a {@link Principal}. All authorization data
 * (roles, tenant membership, block status) comes from PostgreSQL, never from
 * token claims, so revoking access is immediate.
 */
@Injectable()
export class AuthService {
  constructor(
    @Inject(TOKEN_VERIFIER) private readonly verifier: TokenVerifier,
    private readonly prisma: PrismaService,
    private readonly users: UsersService,
  ) {}

  async verifyBearer(authorization: string | undefined): Promise<VerifiedIdentity> {
    if (!authorization) throw AppException.unauthorized(ErrorCode.AUTH_REQUIRED);
    const [scheme, token, ...rest] = authorization.split(' ');
    if (scheme?.toLowerCase() !== 'bearer' || !token || rest.length > 0) {
      throw AppException.unauthorized(ErrorCode.AUTH_TOKEN_INVALID, 'Malformed Authorization header');
    }
    try {
      return await this.verifier.verify(token);
    } catch (err) {
      if (err instanceof TokenVerificationError && err.reason === 'expired') {
        throw AppException.unauthorized(ErrorCode.AUTH_TOKEN_EXPIRED, 'Session expired, please sign in again');
      }
      throw AppException.unauthorized(ErrorCode.AUTH_TOKEN_INVALID, 'Invalid credentials');
    }
  }

  async resolveUserPrincipal(tenant: TenantContext, identity: VerifiedIdentity): Promise<UserPrincipal> {
    const user = await this.users.findOrProvision(tenant.id, identity);
    if (user.status !== 'ACTIVE') {
      throw AppException.forbidden(ErrorCode.ACCOUNT_BLOCKED, 'This account has been blocked');
    }
    const isApprovedCaller = user.callerProfile?.status === 'APPROVED';
    const roles: Role[] = isApprovedCaller ? [Role.USER, Role.CALLER] : [Role.USER];
    return {
      kind: 'user',
      identity,
      userId: user.id,
      tenantId: tenant.id,
      roles,
      permissions: permissionsForRoles(roles),
      callerProfileId: isApprovedCaller && user.callerProfile ? user.callerProfile.id : null,
    };
  }

  async resolveAdminPrincipal(
    identity: VerifiedIdentity,
    tenant: TenantContext | undefined,
  ): Promise<AdminPrincipal> {
    const admin = await this.prisma.adminAccount.findUnique({ where: { firebaseUid: identity.uid } });
    if (!admin || admin.status !== 'ACTIVE') {
      throw AppException.forbidden(ErrorCode.FORBIDDEN, 'No active admin account for this identity');
    }
    // Tenant-scoped admins may only ever act inside their own tenant.
    if (admin.tenantId && tenant && tenant.id !== admin.tenantId) {
      throw AppException.forbidden(ErrorCode.TENANT_MISMATCH, 'You do not have access to this tenant');
    }
    const roles: Role[] = [admin.role];
    return {
      kind: 'admin',
      identity,
      adminId: admin.id,
      tenantId: admin.tenantId,
      roles,
      permissions: permissionsForRoles(roles),
    };
  }
}
