/**
 * Integer coin arithmetic. Coins are the platform's internal currency unit and
 * are ALWAYS whole integers. Fiat prices are stored in minor units (paise,
 * cents) as integers too. No floating point ever touches a balance.
 */

export class CoinAmountError extends RangeError {
  constructor(message: string) {
    super(message);
    this.name = 'CoinAmountError';
  }
}

/** Largest coin amount we allow in a single value (fits comfortably in BIGINT). */
export const MAX_COIN_AMOUNT = Number.MAX_SAFE_INTEGER;

/** Throws unless `value` is a safe, non-negative integer. */
export function assertCoinAmount(value: number, label = 'amount'): number {
  if (typeof value !== 'number' || !Number.isSafeInteger(value)) {
    throw new CoinAmountError(`${label} must be a safe integer, got ${String(value)}`);
  }
  if (value < 0) {
    throw new CoinAmountError(`${label} must not be negative, got ${value}`);
  }
  return value;
}

/** Throws unless `value` is a safe, strictly positive integer. */
export function assertPositiveCoinAmount(value: number, label = 'amount'): number {
  assertCoinAmount(value, label);
  if (value === 0) throw new CoinAmountError(`${label} must be greater than zero`);
  return value;
}

export function addCoins(a: number, b: number): number {
  assertCoinAmount(a, 'a');
  assertCoinAmount(b, 'b');
  const result = a + b;
  if (!Number.isSafeInteger(result)) throw new CoinAmountError('coin addition overflow');
  return result;
}

/** Subtracts `b` from `a`; throws if the result would be negative. */
export function subtractCoins(a: number, b: number): number {
  assertCoinAmount(a, 'a');
  assertCoinAmount(b, 'b');
  if (b > a) throw new CoinAmountError(`insufficient coins: ${a} - ${b} would be negative`);
  return a - b;
}

/**
 * Basis points (1/100 of a percent) are used for commission so that 12.5%
 * is representable exactly as 1250 without decimals.
 */
export const BASIS_POINTS_DENOMINATOR = 10_000;

export function assertBasisPoints(bps: number, label = 'basis points'): number {
  if (!Number.isSafeInteger(bps) || bps < 0 || bps > BASIS_POINTS_DENOMINATOR) {
    throw new CoinAmountError(`${label} must be an integer in [0, 10000], got ${String(bps)}`);
  }
  return bps;
}

export interface CommissionSplit {
  /** Total charged to the payer. */
  gross: number;
  /** Platform share, rounded down so the earner never loses a fractional coin. */
  platform: number;
  /** Earner share: gross - platform. */
  earner: number;
}

/**
 * Splits a gross coin amount between the platform and the earner using an
 * integer basis-point commission. Always satisfies platform + earner === gross.
 */
export function splitCommission(gross: number, commissionBps: number): CommissionSplit {
  assertCoinAmount(gross, 'gross');
  assertBasisPoints(commissionBps, 'commissionBps');
  const platform = Math.floor((gross * commissionBps) / BASIS_POINTS_DENOMINATOR);
  return { gross, platform, earner: gross - platform };
}

/**
 * Number of billable intervals for a call of `durationSeconds`, charging per
 * STARTED interval (a 61-second call at 60-second intervals = 2 intervals).
 * Zero-length calls are not billed.
 */
export function billableIntervals(durationSeconds: number, intervalSeconds: number): number {
  if (!Number.isSafeInteger(durationSeconds) || durationSeconds < 0) {
    throw new CoinAmountError(`durationSeconds must be a non-negative integer`);
  }
  if (!Number.isSafeInteger(intervalSeconds) || intervalSeconds <= 0) {
    throw new CoinAmountError(`intervalSeconds must be a positive integer`);
  }
  if (durationSeconds === 0) return 0;
  return Math.ceil(durationSeconds / intervalSeconds);
}

/** Total coins for a call, given a per-interval rate. */
export function coinsForDuration(
  durationSeconds: number,
  ratePerInterval: number,
  intervalSeconds: number,
): number {
  assertCoinAmount(ratePerInterval, 'ratePerInterval');
  const intervals = billableIntervals(durationSeconds, intervalSeconds);
  const total = intervals * ratePerInterval;
  if (!Number.isSafeInteger(total)) throw new CoinAmountError('coin multiplication overflow');
  return total;
}

/**
 * Whole intervals a balance can afford at a rate. Used to decide how long a
 * call may continue before the server must end it for insufficient balance.
 */
export function affordableIntervals(balance: number, ratePerInterval: number): number {
  assertCoinAmount(balance, 'balance');
  assertPositiveCoinAmount(ratePerInterval, 'ratePerInterval');
  return Math.floor(balance / ratePerInterval);
}

/**
 * Formats a fiat amount stored in minor units (paise/cents) for display.
 * Display-only: never parse the result back into arithmetic.
 */
export function formatMinorUnits(minorUnits: number, currency: string, locale = 'en-IN'): string {
  if (!Number.isSafeInteger(minorUnits)) {
    throw new CoinAmountError('minorUnits must be an integer');
  }
  return new Intl.NumberFormat(locale, { style: 'currency', currency }).format(minorUnits / 100);
}
