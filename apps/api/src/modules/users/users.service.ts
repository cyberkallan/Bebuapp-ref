import { Injectable } from '@nestjs/common';
import { ErrorCode, WalletKind } from '@bebu/shared';

import { AppException } from '../../common/errors/app.exception.js';
import { PrismaService } from '../../infrastructure/database/prisma.service.js';
import type { VerifiedIdentity } from '../../infrastructure/firebase/token-verifier.js';
import type { CallerProfile, User } from '../../generated/prisma/client.js';

export type UserWithCaller = User & { callerProfile: Pick<CallerProfile, 'id' | 'status'> | null };

/** Shape returned to the owning user; excludes internal columns. */
export interface UserProfileView {
  id: string;
  displayName: string;
  avatarUrl: string | null;
  email: string | null;
  phoneNumber: string | null;
  gender: User['gender'];
  country: string | null;
  language: string | null;
  isCaller: boolean;
  createdAt: string;
}

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Returns the tenant-scoped user for a verified identity, provisioning the
   * account and its spending wallet on first sign-in. Provisioning is
   * transactional so a user never exists without a wallet.
   */
  async findOrProvision(tenantId: string, identity: VerifiedIdentity): Promise<UserWithCaller> {
    const include = { callerProfile: { select: { id: true, status: true } } } as const;

    const existing = await this.prisma.user.findUnique({
      where: { tenantId_firebaseUid: { tenantId, firebaseUid: identity.uid } },
      include,
    });
    if (existing) return existing;

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.upsert({
        where: { tenantId_firebaseUid: { tenantId, firebaseUid: identity.uid } },
        update: {},
        create: {
          tenantId,
          firebaseUid: identity.uid,
          authProvider: identity.provider,
          email: identity.email,
          phoneNumber: identity.phoneNumber,
          displayName: '',
        },
        include,
      });
      await tx.wallet.upsert({
        where: { tenantId_kind_userId: { tenantId, kind: WalletKind.USER, userId: user.id } },
        update: {},
        create: { tenantId, kind: WalletKind.USER, userId: user.id },
      });
      return user;
    });
  }

  async requireById(tenantId: string, id: string): Promise<User> {
    const user = await this.prisma.user.findFirst({ where: { id, tenantId } });
    if (!user) throw AppException.notFound(ErrorCode.NOT_FOUND, 'User not found');
    return user;
  }

  async touchLastActive(userId: string): Promise<void> {
    await this.prisma.user.update({ where: { id: userId }, data: { lastActiveAt: new Date() } });
  }

  toProfileView(user: UserWithCaller): UserProfileView {
    return {
      id: user.id,
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      email: user.email,
      phoneNumber: user.phoneNumber,
      gender: user.gender,
      country: user.country,
      language: user.language,
      isCaller: user.callerProfile?.status === 'APPROVED',
      createdAt: user.createdAt.toISOString(),
    };
  }
}
