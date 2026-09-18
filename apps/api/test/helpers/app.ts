import type { INestApplication } from '@nestjs/common';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { Test } from '@nestjs/testing';

import { AppModule } from '../../src/app.module.js';
import { PrismaService } from '../../src/infrastructure/database/prisma.service.js';
import { encodeDevToken } from '../../src/infrastructure/firebase/dev-token-verifier.js';
import { RedisService } from '../../src/infrastructure/redis/redis.service.js';
import { configureApp, registerFallbackNotFound } from '../../src/main.js';

export interface TestApp {
  app: INestApplication;
  prisma: PrismaService;
  redis: RedisService;
  close(): Promise<void>;
}

/** Boots the full application exactly as production does (guards, filters, helmet). */
export async function createTestApp(): Promise<TestApp> {
  const moduleRef = await Test.createTestingModule({ imports: [AppModule] }).compile();
  const app = moduleRef.createNestApplication<NestExpressApplication>({
    bufferLogs: true,
    rawBody: true,
  });
  configureApp(app);
  await app.init();
  registerFallbackNotFound(app);
  const prisma = app.get(PrismaService);
  const redis = app.get(RedisService);
  return { app, prisma, redis, close: () => app.close() };
}

/** Removes every row from every tenant-owned table. Order respects FKs. */
export async function resetDatabase(prisma: PrismaService): Promise<void> {
  await prisma.$executeRawUnsafe(`
    TRUNCATE TABLE
      notification_logs, audit_logs, reports, ratings, call_state_transitions,
      call_billing_intervals, calls, payout_requests, payment_events, payment_orders,
      coin_packages, wallet_transactions, wallets, caller_tenant_visibility,
      caller_profiles, devices, users, admin_accounts, tenants
    RESTART IDENTITY CASCADE
  `);
}

export const userToken = (uid: string, email = `${uid}@example.com`) =>
  `Bearer ${encodeDevToken({ uid, email, provider: 'google.com' })}`;

export const adminToken = (uid: string) =>
  `Bearer ${encodeDevToken({ uid, email: `${uid}@bebuapp.in` })}`;
