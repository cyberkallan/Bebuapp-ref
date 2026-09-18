import request from 'supertest';

import { adminToken, createTestApp, resetDatabase, type TestApp, userToken } from './helpers/app.js';

describe('platform pipeline (e2e)', () => {
  let t: TestApp;
  let tenantId: string;

  beforeAll(async () => {
    t = await createTestApp();
    await resetDatabase(t.prisma);
    await t.redis.client.flushdb();
    const tenant = await t.prisma.tenant.create({ data: { key: 'bebu', name: 'bebu' } });
    tenantId = tenant.id;
    await t.prisma.tenant.create({ data: { key: 'paused', name: 'Paused', status: 'SUSPENDED' } });
    await t.prisma.adminAccount.create({
      data: { firebaseUid: 'root', email: 'root@bebuapp.in', displayName: 'Root', role: 'SUPER_ADMIN' },
    });
    await t.prisma.adminAccount.create({
      data: {
        firebaseUid: 'bebu-admin',
        email: 'ops@bebuapp.in',
        displayName: 'Ops',
        role: 'TENANT_ADMIN',
        tenantId,
      },
    });
  });

  afterAll(async () => {
    await t.close();
  });

  const http = () => request(t.app.getHttpServer());

  describe('health & metadata', () => {
    it('exposes liveness, readiness and info without auth or tenant', async () => {
      await http().get('/health/live').expect(200);
      const ready = await http().get('/health/ready').expect(200);
      expect(ready.body.info.postgres.status).toBe('up');
      expect(ready.body.info.redis.status).toBe('up');
      const info = await http().get('/').expect(200);
      expect(info.body.name).toBe('bebu-api');
    });

    it('echoes and generates request ids and sets security headers', async () => {
      const res = await http().get('/health/live').set('x-request-id', 'trace-12345678').expect(200);
      expect(res.headers['x-request-id']).toBe('trace-12345678');
      expect(res.headers['x-powered-by']).toBeUndefined();
      expect(res.headers['x-content-type-options']).toBe('nosniff');
      const generated = await http().get('/health/live').expect(200);
      expect(generated.headers['x-request-id']).toMatch(/^[0-9a-f-]{36}$/);
    });

    it('returns the JSON error envelope for unknown routes inside and outside the prefix', async () => {
      const inside = await http().get('/api/v1/nope').expect(404);
      expect(inside.body).toMatchObject({ statusCode: 404, code: 'NOT_FOUND' });
      expect(inside.body.requestId).toBeTruthy();
      const outside = await http().get('/nope').expect(404);
      expect(outside.body).toMatchObject({ statusCode: 404, code: 'NOT_FOUND' });
    });
  });

  describe('tenant resolution', () => {
    it('requires X-Tenant-Key on user routes', async () => {
      const res = await http().get('/api/v1/users/me').set('authorization', userToken('u1')).expect(400);
      expect(res.body.code).toBe('TENANT_HEADER_MISSING');
    });

    it('rejects unknown and malformed tenant keys', async () => {
      expect((await http().get('/api/v1/tenant/config').set('x-tenant-key', 'ghost').expect(404)).body.code).toBe(
        'TENANT_NOT_FOUND',
      );
      expect((await http().get('/api/v1/tenant/config').set('x-tenant-key', 'Not Valid').expect(400)).body.code).toBe(
        'TENANT_NOT_FOUND',
      );
    });

    it('serves public tenant config with merged feature-flag defaults', async () => {
      const res = await http().get('/api/v1/tenant/config').set('x-tenant-key', 'bebu').expect(200);
      expect(res.body.key).toBe('bebu');
      expect(res.body.featureFlags).toMatchObject({ voiceCalls: true, sharedCallerPool: false });
      expect(res.body.pricing).toBeUndefined();
    });

    it('blocks users of a suspended tenant but not admins', async () => {
      const res = await http()
        .get('/api/v1/users/me')
        .set('x-tenant-key', 'paused')
        .set('authorization', userToken('u1'))
        .expect(403);
      expect(res.body.code).toBe('TENANT_SUSPENDED');
      await http().get('/api/v1/admin/me').set('x-tenant-key', 'paused').set('authorization', adminToken('root')).expect(200);
    });
  });

  describe('authentication & provisioning', () => {
    it('requires a bearer token and rejects invalid ones with stable codes', async () => {
      expect((await http().get('/api/v1/users/me').set('x-tenant-key', 'bebu').expect(401)).body.code).toBe(
        'AUTH_REQUIRED',
      );
      expect(
        (await http().get('/api/v1/users/me').set('x-tenant-key', 'bebu').set('authorization', 'Bearer nope').expect(401))
          .body.code,
      ).toBe('AUTH_TOKEN_INVALID');
      expect(
        (await http().get('/api/v1/users/me').set('x-tenant-key', 'bebu').set('authorization', 'Basic abc').expect(401))
          .body.code,
      ).toBe('AUTH_TOKEN_INVALID');
    });

    it('provisions the user and a wallet on first sign-in, once per tenant', async () => {
      const first = await http().get('/api/v1/users/me').set('x-tenant-key', 'bebu').set('authorization', userToken('u1')).expect(200);
      const second = await http().get('/api/v1/users/me').set('x-tenant-key', 'bebu').set('authorization', userToken('u1')).expect(200);
      expect(first.body.id).toBe(second.body.id);
      expect(first.body.email).toBe('u1@example.com');

      const wallet = await http().get('/api/v1/wallet').set('x-tenant-key', 'bebu').set('authorization', userToken('u1')).expect(200);
      expect(wallet.body).toMatchObject({ balance: 0, held: 0, available: 0, currency: 'COIN' });

      expect(await t.prisma.user.count({ where: { tenantId } })).toBe(1);
      expect(await t.prisma.wallet.count({ where: { tenantId, kind: 'USER' } })).toBe(1);
    });

    it('blocks blocked users', async () => {
      await t.prisma.user.updateMany({ where: { firebaseUid: 'u1' }, data: { status: 'BLOCKED' } });
      const res = await http().get('/api/v1/wallet').set('x-tenant-key', 'bebu').set('authorization', userToken('u1')).expect(403);
      expect(res.body.code).toBe('ACCOUNT_BLOCKED');
      await t.prisma.user.updateMany({ where: { firebaseUid: 'u1' }, data: { status: 'ACTIVE' } });
    });
  });

  describe('admin RBAC & tenant isolation', () => {
    it('denies admin routes to identities without an admin account', async () => {
      const res = await http().get('/api/v1/admin/me').set('authorization', userToken('u1')).expect(403);
      expect(res.body.code).toBe('FORBIDDEN');
    });

    it('lets the super admin see every tenant and create new ones with an audit trail', async () => {
      const list = await http().get('/api/v1/admin/tenants').set('authorization', adminToken('root')).expect(200);
      expect(list.body.map((x: { key: string }) => x.key).sort()).toEqual(['bebu', 'paused']);

      const created = await http()
        .post('/api/v1/admin/tenants')
        .set('authorization', adminToken('root'))
        .send({ key: 'app-c', name: 'App C', iosBundleId: 'in.example.appc' })
        .expect(201);
      expect(created.body.key).toBe('app-c');
      expect(created.body.pricing.currency).toBe('INR');

      const audit = await t.prisma.auditLog.findMany({ where: { action: 'TENANT_CREATED' } });
      expect(audit).toHaveLength(1);
      expect(audit[0]?.actorType).toBe('ADMIN');
      expect(audit[0]?.requestId).toBeTruthy();
    });

    it('returns field-level validation details without echoing input', async () => {
      const res = await http()
        .post('/api/v1/admin/tenants')
        .set('authorization', adminToken('root'))
        .send({ key: 'BAD KEY', name: '' })
        .expect(400);
      expect(res.body.code).toBe('VALIDATION_FAILED');
      expect(res.body.details.map((d: { path: string }) => d.path).sort()).toEqual(['body.key', 'body.name']);
      expect(JSON.stringify(res.body)).not.toContain('BAD KEY');
    });

    it('scopes tenant admins to their own tenant and forbids privileged actions', async () => {
      const list = await http().get('/api/v1/admin/tenants').set('authorization', adminToken('bebu-admin')).expect(200);
      expect(list.body).toHaveLength(1);
      expect(list.body[0].key).toBe('bebu');

      const other = await t.prisma.tenant.findUniqueOrThrow({ where: { key: 'paused' } });
      await http().get(`/api/v1/admin/tenants/${other.id}`).set('authorization', adminToken('bebu-admin')).expect(403);

      expect(
        (await http().post('/api/v1/admin/tenants').set('authorization', adminToken('bebu-admin')).send({ key: 'x-y', name: 'X' }).expect(403))
          .body.code,
      ).toBe('FORBIDDEN');

      expect(
        (
          await http()
            .get('/api/v1/admin/me')
            .set('x-tenant-key', 'paused')
            .set('authorization', adminToken('bebu-admin'))
            .expect(403)
        ).body.code,
      ).toBe('TENANT_MISMATCH');

      expect(
        (
          await http()
            .patch(`/api/v1/admin/tenants/${tenantId}`)
            .set('authorization', adminToken('bebu-admin'))
            .send({ status: 'SUSPENDED' })
            .expect(403)
        ).body.code,
      ).toBe('FORBIDDEN');

      const updated = await http()
        .patch(`/api/v1/admin/tenants/${tenantId}`)
        .set('authorization', adminToken('bebu-admin'))
        .send({ branding: { primaryColor: '#123456' }, featureFlags: { chat: true } })
        .expect(200);
      expect(updated.body.branding.primaryColor).toBe('#123456');
      expect(updated.body.featureFlags.chat).toBe(true);
      expect(updated.body.featureFlags.voiceCalls).toBe(true);
    });
  });
});
