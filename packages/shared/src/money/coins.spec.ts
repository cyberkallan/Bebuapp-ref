import { describe, expect, it } from 'vitest';

import {
  CoinAmountError,
  addCoins,
  affordableIntervals,
  assertCoinAmount,
  assertPositiveCoinAmount,
  billableIntervals,
  coinsForDuration,
  splitCommission,
  subtractCoins,
} from './coins.js';

describe('coin arithmetic', () => {
  it('rejects non-integer, negative and unsafe amounts', () => {
    expect(() => assertCoinAmount(1.5)).toThrow(CoinAmountError);
    expect(() => assertCoinAmount(-1)).toThrow(CoinAmountError);
    expect(() => assertCoinAmount(Number.NaN)).toThrow(CoinAmountError);
    expect(() => assertCoinAmount(Number.MAX_SAFE_INTEGER + 1)).toThrow(CoinAmountError);
    expect(() => assertCoinAmount('10' as unknown as number)).toThrow(CoinAmountError);
    expect(assertCoinAmount(0)).toBe(0);
    expect(() => assertPositiveCoinAmount(0)).toThrow(CoinAmountError);
    expect(assertPositiveCoinAmount(1)).toBe(1);
  });

  it('adds and subtracts without going negative', () => {
    expect(addCoins(10, 5)).toBe(15);
    expect(subtractCoins(10, 5)).toBe(5);
    expect(subtractCoins(10, 10)).toBe(0);
    expect(() => subtractCoins(5, 10)).toThrow(CoinAmountError);
    expect(() => addCoins(Number.MAX_SAFE_INTEGER, 1)).toThrow(CoinAmountError);
  });

  it('splits commission with integer basis points and no lost coins', () => {
    expect(splitCommission(100, 2_000)).toEqual({ gross: 100, platform: 20, earner: 80 });
    expect(splitCommission(7, 3_333)).toEqual({ gross: 7, platform: 2, earner: 5 });
    expect(splitCommission(0, 5_000)).toEqual({ gross: 0, platform: 0, earner: 0 });
    expect(splitCommission(100, 0)).toEqual({ gross: 100, platform: 0, earner: 100 });
    expect(splitCommission(100, 10_000)).toEqual({ gross: 100, platform: 100, earner: 0 });
    for (let gross = 0; gross < 500; gross += 7) {
      const s = splitCommission(gross, 1_250);
      expect(s.platform + s.earner).toBe(gross);
    }
    expect(() => splitCommission(100, 10_001)).toThrow(CoinAmountError);
    expect(() => splitCommission(100, 12.5)).toThrow(CoinAmountError);
  });

  it('bills per started interval', () => {
    expect(billableIntervals(0, 60)).toBe(0);
    expect(billableIntervals(1, 60)).toBe(1);
    expect(billableIntervals(60, 60)).toBe(1);
    expect(billableIntervals(61, 60)).toBe(2);
    expect(billableIntervals(3_600, 60)).toBe(60);
    expect(() => billableIntervals(-1, 60)).toThrow(CoinAmountError);
    expect(() => billableIntervals(10, 0)).toThrow(CoinAmountError);
  });

  it('computes total charge for a duration', () => {
    expect(coinsForDuration(0, 10, 60)).toBe(0);
    expect(coinsForDuration(59, 10, 60)).toBe(10);
    expect(coinsForDuration(125, 10, 60)).toBe(30);
  });

  it('computes how many intervals a balance affords', () => {
    expect(affordableIntervals(0, 10)).toBe(0);
    expect(affordableIntervals(9, 10)).toBe(0);
    expect(affordableIntervals(10, 10)).toBe(1);
    expect(affordableIntervals(95, 10)).toBe(9);
    expect(() => affordableIntervals(95, 0)).toThrow(CoinAmountError);
  });
});
