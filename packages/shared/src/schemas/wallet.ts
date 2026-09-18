import { z } from 'zod';

import { ClientPlatform, PaymentProviderKind } from '../domain/payment.js';
import { WalletTransactionType } from '../domain/wallet.js';
import { idSchema, idempotencyKeySchema, paginationQuerySchema } from './common.js';

/** Wallet summary returned to the owning user. Balance is always server-derived. */
export const walletBalanceSchema = z.object({
  walletId: idSchema,
  balance: z.number().int().nonnegative(),
  /** Coins currently reserved by active call holds. */
  held: z.number().int().nonnegative(),
  /** balance - held. What the user can actually spend right now. */
  available: z.number().int().nonnegative(),
  currency: z.literal('COIN'),
  updatedAt: z.iso.datetime(),
});
export type WalletBalance = z.infer<typeof walletBalanceSchema>;

export const walletHistoryQuerySchema = paginationQuerySchema.extend({
  type: z.enum(WalletTransactionType).optional(),
});
export type WalletHistoryQuery = z.infer<typeof walletHistoryQuerySchema>;

/** Admin-only manual adjustment; always audited with a mandatory reason. */
export const adminWalletAdjustmentSchema = z.object({
  userId: idSchema,
  /** Signed integer: positive credits, negative debits. */
  deltaCoins: z
    .number()
    .int()
    .safe()
    .refine((v) => v !== 0, 'delta must be non-zero'),
  reason: z.string().min(10).max(500),
  idempotencyKey: idempotencyKeySchema,
});
export type AdminWalletAdjustmentInput = z.infer<typeof adminWalletAdjustmentSchema>;

/** Step 1 of a purchase: server creates an order for a coin package. */
export const createPaymentOrderSchema = z.object({
  coinPackageId: idSchema,
  provider: z.enum(PaymentProviderKind).exclude(['MANUAL']),
  platform: z.enum(ClientPlatform),
  idempotencyKey: idempotencyKeySchema,
});
export type CreatePaymentOrderInput = z.infer<typeof createPaymentOrderSchema>;

/**
 * Step 2: client hands the provider's proof (receipt, purchase token, payment
 * id + signature) to the server. The server verifies with the provider before
 * any coins move. Shape is provider-specific and validated by the provider.
 */
export const submitPaymentProofSchema = z.object({
  orderId: idSchema,
  providerPayload: z.record(z.string(), z.unknown()),
});
export type SubmitPaymentProofInput = z.infer<typeof submitPaymentProofSchema>;
