import { Controller, Get } from '@nestjs/common';
import type { WalletBalance } from '@bebu/shared';

import { CurrentPrincipal } from '../auth/decorators/current-principal.decorator.js';
import type { UserPrincipal } from '../auth/principal.js';
import { WalletService } from './wallet.service.js';

@Controller('wallet')
export class WalletController {
  constructor(private readonly wallet: WalletService) {}

  /** Server-derived balance. The client must never compute this locally. */
  @Get()
  balance(@CurrentPrincipal() principal: UserPrincipal): Promise<WalletBalance> {
    return this.wallet.getBalance(principal.tenantId, principal.userId);
  }
}
