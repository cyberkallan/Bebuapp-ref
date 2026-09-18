import { Injectable } from '@nestjs/common';
import {
  ErrorCode,
  type LedgerDirection,
  type LedgerReferenceType,
  WALLET_TRANSACTION_DIRECTION,
  type WalletKind,
  type WalletTransactionType,
  assertPositiveCoinAmount,
} from '@bebu/shared';

import { AppException } from '../../common/errors/app.exception.js';
import type { DbTransaction } from '../../infrastructure/database/prisma.service.js';
import type { Prisma, WalletTransaction } from '../../generated/prisma/client.js';

export interface LedgerActor {
  type: 'USER' | 'ADMIN' | 'SYSTEM';
  id: string | null;
}

export interface LedgerEntryInput {
  tenantId: string;
  walletId: string;
  type: WalletTransactionType;
  /** Absolute coins, > 0. Direction comes from the type (or `direction`). */
  amount: number;
  /** Required only for ADMIN_ADJUSTMENT, where the type alone is ambiguous. */
  direction?: LedgerDirection;
  idempotencyKey: string;
  referenceType?: LedgerReferenceType;
  referenceId?: string;
  actor: LedgerActor;
  metadata?: Record<string, unknown>;
}

export interface LedgerEntryResult {
  transaction: WalletTransaction;
  /** True when the idempotency key had already been applied. */
  replayed: boolean;
}

interface LockedWalletRow {
  id: string;
  tenantId: string;
  kind: WalletKind;
  balance: bigint;
  heldBalance: bigint;
}

/**
 * The single primitive through which coins move. Everything else in the
 * wallet/payments/calls modules composes this inside a
 * `PrismaService.financialTransaction`.
 *
 * Guarantees:
 * - Row lock (`SELECT ... FOR UPDATE`) on the wallet, so concurrent entries
 *   for one wallet serialise and balance_before/after are exact.
 * - Idempotent per (tenantId, idempotencyKey): a replay returns the original
 *   row and moves no coins.
 * - Debits never take the balance below zero (INSUFFICIENT_BALANCE).
 * - Integer-only arithmetic in BIGINT.
 */
@Injectable()
export class WalletLedgerService {
  async apply(tx: DbTransaction, input: LedgerEntryInput): Promise<LedgerEntryResult> {
    assertPositiveCoinAmount(input.amount, 'amount');
    const direction = this.resolveDirection(input);

    const existing = await tx.walletTransaction.findUnique({
      where: { tenantId_idempotencyKey: { tenantId: input.tenantId, idempotencyKey: input.idempotencyKey } },
    });
    if (existing) {
      if (existing.walletId !== input.walletId || existing.amount !== BigInt(input.amount)) {
        throw AppException.conflict(
          ErrorCode.IDEMPOTENCY_KEY_REUSED,
          'Idempotency key was already used with different parameters',
        );
      }
      return { transaction: existing, replayed: true };
    }

    // Column identifiers are camelCase (Prisma default); only tables are @@map'ed.
    const rows = await tx.$queryRaw<LockedWalletRow[]>`
      SELECT id, "tenantId", kind, balance, "heldBalance"
      FROM wallets
      WHERE id = ${input.walletId}::uuid AND "tenantId" = ${input.tenantId}::uuid
      FOR UPDATE
    `;
    const wallet = rows[0];
    if (!wallet) throw AppException.notFound(ErrorCode.WALLET_NOT_FOUND, 'Wallet not found');

    const amount = BigInt(input.amount);
    const balanceBefore = wallet.balance;
    const balanceAfter = direction === 'CREDIT' ? balanceBefore + amount : balanceBefore - amount;
    if (balanceAfter < 0n) {
      throw AppException.unprocessable(ErrorCode.WALLET_INSUFFICIENT_BALANCE, 'Insufficient coin balance');
    }

    await tx.wallet.update({
      where: { id: wallet.id },
      data: { balance: balanceAfter, version: { increment: 1 } },
    });

    const transaction = await tx.walletTransaction.create({
      data: {
        tenantId: input.tenantId,
        walletId: wallet.id,
        type: input.type,
        direction,
        amount,
        balanceBefore,
        balanceAfter,
        referenceType: input.referenceType ?? null,
        referenceId: input.referenceId ?? null,
        idempotencyKey: input.idempotencyKey,
        status: 'POSTED',
        actorType: input.actor.type,
        actorId: input.actor.id,
        metadata: (input.metadata ?? {}) as Prisma.InputJsonObject,
      },
    });

    return { transaction, replayed: false };
  }

  private resolveDirection(input: LedgerEntryInput): LedgerDirection {
    if (input.type === 'ADMIN_ADJUSTMENT') {
      if (!input.direction) {
        throw AppException.badRequest(ErrorCode.WALLET_INVALID_AMOUNT, 'direction is required for adjustments');
      }
      return input.direction;
    }
    const expected = WALLET_TRANSACTION_DIRECTION[input.type];
    if (input.direction && input.direction !== expected) {
      throw AppException.badRequest(
        ErrorCode.WALLET_INVALID_AMOUNT,
        `${input.type} entries must be ${expected}`,
      );
    }
    return expected;
  }
}
