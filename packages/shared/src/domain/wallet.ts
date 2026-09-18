/**
 * Wallet ledger vocabulary. The ledger is append-only: balances are derived
 * from and cross-checked against the sequence of wallet transactions.
 */

/** Who owns a wallet. Callers earn into a separate wallet from the one they spend from. */
export const WalletKind = {
  /** Spendable coins purchased or granted to a user. */
  USER: 'USER',
  /** Coins earned by a caller, redeemable via payout. */
  CALLER_EARNINGS: 'CALLER_EARNINGS',
  /** Platform commission collected per tenant (for reporting/reconciliation). */
  PLATFORM_REVENUE: 'PLATFORM_REVENUE',
} as const;
export type WalletKind = (typeof WalletKind)[keyof typeof WalletKind];

export const WalletTransactionType = {
  /** Coins credited after a verified payment. */
  PURCHASE: 'PURCHASE',
  /** Promotional or onboarding grant (e.g. daily login bonus). */
  BONUS: 'BONUS',
  /** Per-interval debit while a call is connected. */
  CALL_CHARGE: 'CALL_CHARGE',
  /** Caller's share of a call charge. */
  CALL_EARNING: 'CALL_EARNING',
  /** Platform's share of a call charge. */
  PLATFORM_COMMISSION: 'PLATFORM_COMMISSION',
  /** Reversal of a previous charge (server-side dispute resolution). */
  REFUND: 'REFUND',
  /** Coins temporarily reserved before a call connects. */
  HOLD: 'HOLD',
  /** Release of an unused hold. */
  HOLD_RELEASE: 'HOLD_RELEASE',
  /** Caller cash-out request debiting earnings. */
  PAYOUT: 'PAYOUT',
  /** Payout rejected/failed; earnings returned. */
  PAYOUT_REVERSAL: 'PAYOUT_REVERSAL',
  /** Manual correction by an administrator (always audited). */
  ADMIN_ADJUSTMENT: 'ADMIN_ADJUSTMENT',
  /** Payment charged back by the provider. */
  CHARGEBACK: 'CHARGEBACK',
} as const;
export type WalletTransactionType =
  (typeof WalletTransactionType)[keyof typeof WalletTransactionType];

/** Direction of a ledger entry relative to the wallet balance. */
export const LedgerDirection = {
  CREDIT: 'CREDIT',
  DEBIT: 'DEBIT',
} as const;
export type LedgerDirection = (typeof LedgerDirection)[keyof typeof LedgerDirection];

export const WALLET_TRANSACTION_DIRECTION: Readonly<
  Record<WalletTransactionType, LedgerDirection>
> = {
  PURCHASE: LedgerDirection.CREDIT,
  BONUS: LedgerDirection.CREDIT,
  CALL_CHARGE: LedgerDirection.DEBIT,
  CALL_EARNING: LedgerDirection.CREDIT,
  PLATFORM_COMMISSION: LedgerDirection.CREDIT,
  REFUND: LedgerDirection.CREDIT,
  HOLD: LedgerDirection.DEBIT,
  HOLD_RELEASE: LedgerDirection.CREDIT,
  PAYOUT: LedgerDirection.DEBIT,
  PAYOUT_REVERSAL: LedgerDirection.CREDIT,
  ADMIN_ADJUSTMENT: LedgerDirection.CREDIT, // sign carried by amount; see ledger service
  CHARGEBACK: LedgerDirection.DEBIT,
};

export const WalletTransactionStatus = {
  PENDING: 'PENDING',
  POSTED: 'POSTED',
  REVERSED: 'REVERSED',
  FAILED: 'FAILED',
} as const;
export type WalletTransactionStatus =
  (typeof WalletTransactionStatus)[keyof typeof WalletTransactionStatus];

/** What a ledger entry refers to. Stored as (referenceType, referenceId). */
export const LedgerReferenceType = {
  PAYMENT_ORDER: 'PAYMENT_ORDER',
  CALL: 'CALL',
  CALL_BILLING_INTERVAL: 'CALL_BILLING_INTERVAL',
  PAYOUT_REQUEST: 'PAYOUT_REQUEST',
  ADMIN_ACTION: 'ADMIN_ACTION',
  PROMOTION: 'PROMOTION',
} as const;
export type LedgerReferenceType = (typeof LedgerReferenceType)[keyof typeof LedgerReferenceType];

/** Shape of a ledger entry as exposed through the API (never the raw DB row). */
export interface WalletTransactionView {
  id: string;
  tenantId: string;
  walletId: string;
  type: WalletTransactionType;
  direction: LedgerDirection;
  /** Absolute coin amount, integer. */
  amount: number;
  balanceBefore: number;
  balanceAfter: number;
  referenceType: LedgerReferenceType | null;
  referenceId: string | null;
  status: WalletTransactionStatus;
  createdAt: string;
}
