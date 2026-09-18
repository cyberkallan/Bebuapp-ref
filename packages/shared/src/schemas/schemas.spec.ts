import { describe, expect, it } from 'vitest';

import { Role, hasPermission, Permission } from '../domain/roles.js';
import { paginationQuerySchema, tenantKeySchema } from './common.js';
import { createTenantSchema, tenantFeatureFlagsSchema } from './tenant.js';
import { adminWalletAdjustmentSchema, createPaymentOrderSchema } from './wallet.js';
import { requestCallSchema } from './call.js';

describe('shared validation schemas', () => {
  it('validates tenant keys as lowercase slugs', () => {
    expect(tenantKeySchema.safeParse('bebu').success).toBe(true);
    expect(tenantKeySchema.safeParse('app-b2').success).toBe(true);
    expect(tenantKeySchema.safeParse('Bebu').success).toBe(false);
    expect(tenantKeySchema.safeParse('-bebu').success).toBe(false);
    expect(tenantKeySchema.safeParse('a').success).toBe(false);
  });

  it('coerces and bounds pagination', () => {
    expect(paginationQuerySchema.parse({})).toEqual({ limit: 20 });
    expect(paginationQuerySchema.parse({ limit: '50' })).toEqual({ limit: 50 });
    expect(paginationQuerySchema.safeParse({ limit: 1_000 }).success).toBe(false);
  });

  it('rejects unknown feature flags', () => {
    expect(tenantFeatureFlagsSchema.safeParse({ voiceCalls: true }).success).toBe(true);
    expect(tenantFeatureFlagsSchema.safeParse({ freeCoinsForever: true }).success).toBe(false);
  });

  it('validates a tenant creation payload with platform identifiers', () => {
    const parsed = createTenantSchema.parse({
      key: 'bebu',
      name: 'bebu',
      androidPackageName: 'in.bebuapp.android',
      iosBundleId: 'in.bebuapp.ios',
    });
    expect(parsed.supportedCountries).toEqual([]);
    expect(createTenantSchema.safeParse({ key: 'bebu', name: 'x', androidPackageName: 'bad' }).success).toBe(false);
  });

  it('requires non-zero deltas and a reason for admin wallet adjustments', () => {
    const base = {
      userId: '0b8fd4a0-9c21-4a4e-9d4b-6ea3fd9a8b31',
      reason: 'Refund for failed call on 2026-09-18',
      idempotencyKey: 'adj-2026-09-18-0001',
    };
    expect(adminWalletAdjustmentSchema.safeParse({ ...base, deltaCoins: 50 }).success).toBe(true);
    expect(adminWalletAdjustmentSchema.safeParse({ ...base, deltaCoins: -50 }).success).toBe(true);
    expect(adminWalletAdjustmentSchema.safeParse({ ...base, deltaCoins: 0 }).success).toBe(false);
    expect(adminWalletAdjustmentSchema.safeParse({ ...base, deltaCoins: 1.5 }).success).toBe(false);
    expect(adminWalletAdjustmentSchema.safeParse({ ...base, deltaCoins: 5, reason: 'short' }).success).toBe(false);
  });

  it('never lets a client select the MANUAL payment provider', () => {
    const base = {
      coinPackageId: '0b8fd4a0-9c21-4a4e-9d4b-6ea3fd9a8b31',
      platform: 'ANDROID',
      idempotencyKey: 'order-2026-09-18-0001',
    };
    expect(createPaymentOrderSchema.safeParse({ ...base, provider: 'GOOGLE_PLAY' }).success).toBe(true);
    expect(createPaymentOrderSchema.safeParse({ ...base, provider: 'MANUAL' }).success).toBe(false);
  });

  it('defaults call mode to PRIVATE', () => {
    const parsed = requestCallSchema.parse({
      callerId: '0b8fd4a0-9c21-4a4e-9d4b-6ea3fd9a8b31',
      type: 'AUDIO',
      idempotencyKey: 'call-2026-09-18-0001',
    });
    expect(parsed.mode).toBe('PRIVATE');
  });
});

describe('role permissions', () => {
  it('scopes tenant staff away from financial configuration', () => {
    expect(hasPermission([Role.TENANT_STAFF], Permission.WALLET_ADJUST)).toBe(false);
    expect(hasPermission([Role.TENANT_STAFF], Permission.MODERATION_ACT)).toBe(true);
    expect(hasPermission([Role.TENANT_ADMIN], Permission.WALLET_ADJUST)).toBe(true);
    expect(hasPermission([Role.TENANT_ADMIN], Permission.TENANT_CREATE)).toBe(false);
    expect(hasPermission([Role.SUPER_ADMIN], Permission.TENANT_CREATE)).toBe(true);
    expect(hasPermission([Role.USER], Permission.USER_READ)).toBe(false);
  });
});
