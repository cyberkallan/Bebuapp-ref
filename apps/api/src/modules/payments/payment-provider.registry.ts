import { Inject, Injectable } from '@nestjs/common';
import { ErrorCode, type PaymentProviderKind } from '@bebu/shared';

import { AppException } from '../../common/errors/app.exception.js';
import { PAYMENT_PROVIDERS, type PaymentProvider } from './payment-provider.interface.js';

/**
 * Looks up the {@link PaymentProvider} for a kind. Providers register
 * themselves under the PAYMENT_PROVIDERS multi-provider token; a kind with no
 * registered implementation yields PAYMENT_PROVIDER_UNAVAILABLE so clients
 * get a stable error rather than a 500.
 */
@Injectable()
export class PaymentProviderRegistry {
  private readonly byKind: ReadonlyMap<PaymentProviderKind, PaymentProvider>;

  constructor(@Inject(PAYMENT_PROVIDERS) providers: readonly PaymentProvider[]) {
    this.byKind = new Map(providers.map((p) => [p.kind, p]));
  }

  get(kind: PaymentProviderKind): PaymentProvider {
    const provider = this.byKind.get(kind);
    if (!provider) {
      throw AppException.serviceUnavailable(
        ErrorCode.PAYMENT_PROVIDER_UNAVAILABLE,
        `Payment provider ${kind} is not available`,
      );
    }
    return provider;
  }

  available(): readonly PaymentProviderKind[] {
    return [...this.byKind.keys()];
  }
}
