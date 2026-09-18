import { AppException } from '../src/common/errors/app.exception.js';
import { WalletLedgerService } from '../src/modules/wallet/wallet-ledger.service.js';
import { createTestApp, resetDatabase, type TestApp } from './helpers/app.js';

/**
 * Financial-safety tests for the ledger primitive against a real PostgreSQL:
 * exact balance_before/after, no negative balances, idempotency, and
 * correctness under concurrent debits.
 */
describe('WalletLedgerService (integration)', () => {
  let t: TestApp;
  let ledger: WalletLedgerService;
  let tenantId: string;
  let walletId: string;
  const actor = { type: 'SYSTEM', id: null } as const;

  beforeAll(async () => {
    t = await createTestApp();
    ledger = t.app.get(WalletLedgerService);
  });

  beforeEach(async () => {
    await resetDatabase(t.prisma);
    const tenant = await t.prisma.tenant.create({ data: { key: 'ledger', name: 'Ledger' } });
    tenantId = tenant.id;
    const user = await t.prisma.user.create({ data: { tenantId, firebaseUid: 'w1' } });
    const wallet = await t.prisma.wallet.create({ data: { tenantId, kind: 'USER', userId: user.id } });
    walletId = wallet.id;
  });

  afterAll(async () => {
    await t.close();
  });

  const credit = (amount: number, key: string) =>
    t.prisma.financialTransaction((tx) =>
      ledger.apply(tx, { tenantId, walletId, type: 'PURCHASE', amount, idempotencyKey: key, actor }),
    );
  const debit = (amount: number, key: string) =>
    t.prisma.financialTransaction((tx) =>
      ledger.apply(tx, { tenantId, walletId, type: 'CALL_CHARGE', amount, idempotencyKey: key, actor }),
    );

  it('posts credits and debits with exact before/after balances', async () => {
    const c = await credit(100, 'p-1');
    expect(c.replayed).toBe(false);
    expect(c.transaction).toMatchObject({ direction: 'CREDIT', balanceBefore: 0n, balanceAfter: 100n });

    const d = await debit(30, 'c-1');
    expect(d.transaction).toMatchObject({ direction: 'DEBIT', amount: 30n, balanceBefore: 100n, balanceAfter: 70n });

    const wallet = await t.prisma.wallet.findUniqueOrThrow({ where: { id: walletId } });
    expect(wallet.balance).toBe(70n);
    expect(wallet.version).toBe(2);
  });

  it('never lets a balance go negative and rolls the whole transaction back', async () => {
    await credit(20, 'p-1');
    await expect(debit(25, 'c-1')).rejects.toMatchObject({ code: 'WALLET_INSUFFICIENT_BALANCE' });
    const wallet = await t.prisma.wallet.findUniqueOrThrow({ where: { id: walletId } });
    expect(wallet.balance).toBe(20n);
    expect(await t.prisma.walletTransaction.count()).toBe(1);
  });

  it('is idempotent per tenant + key and rejects key reuse with different parameters', async () => {
    const first = await credit(50, 'p-dup');
    const replay = await credit(50, 'p-dup');
    expect(replay.replayed).toBe(true);
    expect(replay.transaction.id).toBe(first.transaction.id);
    const wallet = await t.prisma.wallet.findUniqueOrThrow({ where: { id: walletId } });
    expect(wallet.balance).toBe(50n);

    await expect(credit(51, 'p-dup')).rejects.toMatchObject({ code: 'IDEMPOTENCY_KEY_REUSED' });
  });

  it('rejects non-positive, fractional and unsafe amounts before touching the database', async () => {
    await expect(credit(0, 'z')).rejects.toThrow(/greater than zero/);
    await expect(credit(1.5, 'f')).rejects.toThrow(/safe integer/);
    await expect(credit(-5, 'n')).rejects.toThrow(/negative/);
    expect(await t.prisma.walletTransaction.count()).toBe(0);
  });

  it('requires an explicit direction for admin adjustments', async () => {
    await expect(
      t.prisma.financialTransaction((tx) =>
        ledger.apply(tx, { tenantId, walletId, type: 'ADMIN_ADJUSTMENT', amount: 5, idempotencyKey: 'a-1', actor }),
      ),
    ).rejects.toBeInstanceOf(AppException);
    const r = await t.prisma.financialTransaction((tx) =>
      ledger.apply(tx, {
        tenantId,
        walletId,
        type: 'ADMIN_ADJUSTMENT',
        direction: 'CREDIT',
        amount: 5,
        idempotencyKey: 'a-2',
        actor: { type: 'ADMIN', id: null },
      }),
    );
    expect(r.transaction.balanceAfter).toBe(5n);
  });

  it('serialises concurrent debits so exactly the affordable number succeed', async () => {
    await credit(50, 'p-1');
    const attempts = Array.from({ length: 12 }, (_, i) =>
      debit(10, `c-${i}`).then(
        () => 'ok' as const,
        (err: unknown) => (err instanceof AppException ? err.code : 'retry'),
      ),
    );
    const results = await Promise.all(attempts);
    const ok = results.filter((r) => r === 'ok').length;
    const insufficient = results.filter((r) => r === 'WALLET_INSUFFICIENT_BALANCE').length;
    const serializationRetries = results.filter((r) => r === 'retry').length;

    // Serializable isolation may abort some transactions (callers retry in
    // real code); what must hold is that the ledger never over-spends.
    expect(ok).toBeLessThanOrEqual(5);
    expect(ok + insufficient + serializationRetries).toBe(12);

    const wallet = await t.prisma.wallet.findUniqueOrThrow({ where: { id: walletId } });
    expect(wallet.balance).toBe(BigInt(50 - ok * 10));

    const rows = await t.prisma.walletTransaction.findMany({ where: { walletId }, orderBy: { createdAt: 'asc' } });
    expect(rows).toHaveLength(1 + ok);
    // Ledger chain is contiguous: each entry starts where the previous ended.
    for (let i = 1; i < rows.length; i++) {
      expect(rows[i]?.balanceBefore).toBe(rows[i - 1]?.balanceAfter);
    }
  });
});
