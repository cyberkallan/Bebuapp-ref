import { Module } from '@nestjs/common';

import { WalletModule } from '../wallet/wallet.module.js';
import { PAYMENT_PROVIDERS } from './payment-provider.interface.js';
import { PaymentProviderRegistry } from './payment-provider.registry.js';

/**
 * Provider-agnostic payments. Concrete providers (WebPaymentProvider,
 * GooglePlayProvider, AppleIapProvider) are added to the PAYMENT_PROVIDERS
 * array in a later stage; until then every purchase attempt returns
 * PAYMENT_PROVIDER_UNAVAILABLE.
 *
 * Planned flow (see docs/architecture.md):
 *   POST /payments/orders        -> PaymentOrder(CREATED) + provider order
 *   POST /payments/orders/:id/verify -> verifyPurchase -> financialTransaction:
 *        PaymentOrder(COMPLETED) + WalletLedgerService.apply(PURCHASE)
 *   POST /payments/webhooks/:provider -> PaymentEvent (unique) -> reconcile
 */
@Module({
  imports: [WalletModule],
  providers: [{ provide: PAYMENT_PROVIDERS, useValue: [] }, PaymentProviderRegistry],
  exports: [PaymentProviderRegistry],
})
export class PaymentsModule {}
