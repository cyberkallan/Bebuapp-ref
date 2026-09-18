import type { PaymentProviderKind } from '@bebu/shared';

/**
 * Contract every payment integration implements. The wallet never talks to a
 * provider directly; it only reacts to a {@link VerifiedPurchase} produced
 * here after server-side verification.
 */
export interface CreateProviderOrderInput {
  tenantId: string;
  orderId: string;
  userId: string;
  amountMinorUnits: number;
  currency: string;
  /** Store product id for IAP providers, package id for web. */
  productReference: string;
  metadata?: Record<string, string>;
}

export interface ProviderOrder {
  /** Provider-side identifier to persist on PaymentOrder.providerOrderId. */
  providerOrderId: string;
  /** Anything the client SDK needs to start checkout (never secrets). */
  clientPayload: Record<string, unknown>;
  expiresAt: Date | null;
}

export interface VerifiedPurchase {
  providerOrderId: string;
  /** Provider's own transaction/purchase identifier, for dedupe. */
  providerTransactionId: string;
  amountMinorUnits: number;
  currency: string;
  paidAt: Date;
  raw: Record<string, unknown>;
}

export interface ProviderWebhookEvent {
  providerEventId: string;
  eventType: string;
  providerOrderId: string | null;
  signatureValid: boolean;
  payload: Record<string, unknown>;
}

export interface PaymentProvider {
  readonly kind: PaymentProviderKind;

  /** Step 1: create a provider-side order for a server-created PaymentOrder. */
  createOrder(input: CreateProviderOrderInput): Promise<ProviderOrder>;

  /**
   * Step 2: verify the client's proof (payment id + signature, purchase token,
   * receipt) directly with the provider. Must throw on any mismatch. Must be
   * safe to call repeatedly for the same proof.
   */
  verifyPurchase(orderId: string, providerPayload: Record<string, unknown>): Promise<VerifiedPurchase>;

  /**
   * Parse and authenticate an inbound webhook. Returns a normalised event;
   * the caller persists it (PaymentEvent) before acting on it.
   */
  parseWebhook(rawBody: Buffer, headers: Record<string, string | string[] | undefined>): Promise<ProviderWebhookEvent>;

  /** Acknowledge consumption with the store (Google Play) if applicable. */
  acknowledge?(purchase: VerifiedPurchase): Promise<void>;
}

/** DI token for the list of registered providers. */
export const PAYMENT_PROVIDERS = Symbol('PAYMENT_PROVIDERS');
