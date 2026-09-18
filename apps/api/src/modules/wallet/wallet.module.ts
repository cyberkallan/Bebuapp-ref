import { Module } from '@nestjs/common';

import { WalletLedgerService } from './wallet-ledger.service.js';
import { WalletController } from './wallet.controller.js';
import { WalletService } from './wallet.service.js';

@Module({
  controllers: [WalletController],
  providers: [WalletService, WalletLedgerService],
  exports: [WalletService, WalletLedgerService],
})
export class WalletModule {}
