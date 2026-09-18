import { Injectable, type OnModuleDestroy, type OnModuleInit } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PinoLogger } from 'nestjs-pino';

import { AppConfig } from '../../config/app-config.js';
import { Prisma, PrismaClient } from '../../generated/prisma/client.js';

/** Prisma transaction client type usable by repositories/services. */
export type DbTransaction = Parameters<Parameters<PrismaClient['$transaction']>[0]>[0];

/**
 * Single PrismaClient for the process, wired to the node-postgres driver
 * adapter. Also exposes the transaction helper every financial operation must
 * use: SERIALIZABLE isolation plus bounded wait/timeouts.
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  constructor(
    private readonly config: AppConfig,
    private readonly logger: PinoLogger,
  ) {
    const adapter = new PrismaPg({
      connectionString: config.database.url,
      max: config.database.poolMax,
      application_name: 'bebu-api',
    });
    const log: Prisma.LogDefinition[] = config.isProduction
      ? [{ emit: 'event', level: 'error' }]
      : [
          { emit: 'event', level: 'error' },
          { emit: 'event', level: 'warn' },
        ];
    super({ adapter, log });
    this.logger.setContext(PrismaService.name);
    // The subclass cannot carry the constructor's inferred log generics, so
    // narrow explicitly to the levels configured above.
    const events = this as unknown as PrismaClient<'error' | 'warn'>;
    events.$on('error', (e) => this.logger.error({ target: e.target }, e.message));
    events.$on('warn', (e) => this.logger.warn({ target: e.target }, e.message));
  }

  async onModuleInit(): Promise<void> {
    await this.$connect();
    this.logger.info('database connected');
  }

  async onModuleDestroy(): Promise<void> {
    await this.$disconnect();
  }

  /** Cheap connectivity probe for health checks. */
  async ping(): Promise<void> {
    await this.$queryRaw`SELECT 1`;
  }

  /**
   * Runs `fn` in an interactive transaction with the isolation level used for
   * all balance-changing work. Callers must keep the closure short and must
   * not perform network I/O other than database queries inside it.
   */
  financialTransaction<T>(fn: (tx: DbTransaction) => Promise<T>): Promise<T> {
    return this.$transaction(fn, {
      isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
      maxWait: 5_000,
      timeout: 15_000,
    });
  }
}
