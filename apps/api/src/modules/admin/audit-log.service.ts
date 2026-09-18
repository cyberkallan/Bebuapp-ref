import { Injectable } from '@nestjs/common';
import type { AuditAction } from '@bebu/shared';

import { type DbTransaction, PrismaService } from '../../infrastructure/database/prisma.service.js';
import type { AdminPrincipal } from '../auth/principal.js';

export interface AuditEntry {
  tenantId: string | null;
  actor: { type: 'ADMIN' | 'SYSTEM' | 'USER'; id: string | null };
  action: AuditAction;
  targetType: string;
  targetId: string | null;
  before?: unknown;
  after?: unknown;
  reason?: string;
  requestId?: string;
  ipAddress?: string;
}

/**
 * Append-only audit trail for privileged actions. Pass the same `tx` as the
 * mutation so the audit row commits atomically with the change it records.
 */
@Injectable()
export class AuditLogService {
  constructor(private readonly prisma: PrismaService) {}

  async record(entry: AuditEntry, tx?: DbTransaction): Promise<void> {
    const client = tx ?? this.prisma;
    await client.auditLog.create({
      data: {
        tenantId: entry.tenantId,
        actorType: entry.actor.type,
        actorId: entry.actor.id,
        action: entry.action,
        targetType: entry.targetType,
        targetId: entry.targetId,
        before: entry.before === undefined ? undefined : toJson(entry.before),
        after: entry.after === undefined ? undefined : toJson(entry.after),
        reason: entry.reason ?? null,
        requestId: entry.requestId ?? null,
        ipAddress: entry.ipAddress ?? null,
      },
    });
  }

  static actorOf(principal: AdminPrincipal): AuditEntry['actor'] {
    return { type: 'ADMIN', id: principal.adminId };
  }
}

/** Strips undefined/bigint so arbitrary records can be stored as JSON. */
function toJson(value: unknown): object {
  return JSON.parse(
    JSON.stringify(value, (_k, v: unknown) => (typeof v === 'bigint' ? v.toString() : v)),
  ) as object;
}
