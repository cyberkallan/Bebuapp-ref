import { Injectable } from '@nestjs/common';
import { ErrorCode, type WalletBalance, WalletKind } from '@bebu/shared';

import { AppException } from '../../common/errors/app.exception.js';
import { PrismaService } from '../../infrastructure/database/prisma.service.js';
import type { Wallet } from '../../generated/prisma/client.js';

/**
 * Read model and wallet lookup. Balance-changing operations (purchase credit,
 * call charges, payouts, adjustments) are built on {@link WalletLedgerService}
 * by their owning modules in later stages.
 */
@Injectable()
export class WalletService {
  constructor(private readonly prisma: PrismaService) {}

  async requireUserWallet(tenantId: string, userId: string): Promise<Wallet> {
    const wallet = await this.prisma.wallet.findUnique({
      where: { tenantId_kind_userId: { tenantId, kind: WalletKind.USER, userId } },
    });
    if (!wallet) throw AppException.notFound(ErrorCode.WALLET_NOT_FOUND, 'Wallet not found');
    return wallet;
  }

  async getBalance(tenantId: string, userId: string): Promise<WalletBalance> {
    const wallet = await this.requireUserWallet(tenantId, userId);
    return this.toBalanceView(wallet);
  }

  toBalanceView(wallet: Wallet): WalletBalance {
    const balance = Number(wallet.balance);
    const held = Number(wallet.heldBalance);
    return {
      walletId: wallet.id,
      balance,
      held,
      available: Math.max(0, balance - held),
      currency: 'COIN',
      updatedAt: wallet.updatedAt.toISOString(),
    };
  }
}
