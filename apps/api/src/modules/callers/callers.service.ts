import { Injectable } from '@nestjs/common';
import { type CallerRates, type CallerStatus, ErrorCode } from '@bebu/shared';

import { AppException } from '../../common/errors/app.exception.js';
import { PrismaService } from '../../infrastructure/database/prisma.service.js';
import type { CallerProfile } from '../../generated/prisma/client.js';

/** Caller card shown in discovery lists. Never includes earnings or documents. */
export interface CallerCardView {
  id: string;
  displayName: string;
  bio: string;
  languages: readonly string[];
  topics: readonly string[];
  rates: CallerRates;
  /** Average rating x100 as an integer (e.g. 457 = 4.57), null when unrated. */
  ratingHundredths: number | null;
  ratingCount: number;
  totalCalls: number;
}

/**
 * Caller (consultant) profiles. Live availability is NOT here; it lives in
 * Redis and is owned by the presence service (matching module).
 *
 * Foundation only: read paths and the tenant-visibility rule. Onboarding,
 * review workflow and rate management arrive in a later stage.
 */
@Injectable()
export class CallersService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * A caller is visible in tenant T when:
   *   - home tenant is T and status is APPROVED, or
   *   - sharedAcrossTenants is true, status is APPROVED and an enabled
   *     CallerTenantVisibility row exists for T (explicit allow-list), and
   *     T has the `sharedCallerPool` feature flag on (checked by the caller).
   */
  async requireVisibleInTenant(
    tenantId: string,
    callerProfileId: string,
    sharedPoolEnabled: boolean,
  ): Promise<CallerProfile> {
    const caller = await this.prisma.callerProfile.findFirst({
      where: {
        id: callerProfileId,
        status: 'APPROVED',
        OR: [
          { tenantId },
          ...(sharedPoolEnabled
            ? [{ sharedAcrossTenants: true, visibility: { some: { tenantId, enabled: true } } }]
            : []),
        ],
      },
    });
    if (!caller) throw AppException.notFound(ErrorCode.CALLER_NOT_FOUND, 'Caller not found');
    return caller;
  }

  async findByUserId(userId: string): Promise<CallerProfile | null> {
    return this.prisma.callerProfile.findUnique({ where: { userId } });
  }

  toCardView(caller: CallerProfile): CallerCardView {
    return {
      id: caller.id,
      displayName: caller.displayName,
      bio: caller.bio,
      languages: caller.languages,
      topics: caller.topics,
      rates: {
        privateAudioPerMinute: caller.privateAudioPerMinute,
        privateVideoPerMinute: caller.privateVideoPerMinute,
        randomAudioPerMinute: caller.randomAudioPerMinute,
        randomVideoPerMinute: caller.randomVideoPerMinute,
      },
      ratingHundredths:
        caller.ratingCount > 0 ? Math.round((caller.ratingSum * 100) / caller.ratingCount) : null,
      ratingCount: caller.ratingCount,
      totalCalls: caller.totalCalls,
    };
  }

  statusOf(caller: CallerProfile): CallerStatus {
    return caller.status;
  }
}
