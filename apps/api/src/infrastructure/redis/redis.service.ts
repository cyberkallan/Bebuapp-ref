import { randomUUID } from 'node:crypto';

import { Injectable, type OnModuleDestroy, type OnModuleInit } from '@nestjs/common';
import { Redis } from 'ioredis';
import { PinoLogger } from 'nestjs-pino';

import { AppConfig } from '../../config/app-config.js';

export class LockNotAcquiredError extends Error {
  constructor(public readonly key: string) {
    super(`Could not acquire lock ${key}`);
    this.name = 'LockNotAcquiredError';
  }
}

/** Release only if we still own the lock (compare-and-delete). */
const RELEASE_LOCK_SCRIPT = `
if redis.call("GET", KEYS[1]) == ARGV[1] then
  return redis.call("DEL", KEYS[1])
end
return 0
`;

/**
 * Redis is used ONLY for ephemeral state: presence, availability, active call
 * state, locks, rate limits, queues and caches. It is never the source of
 * truth for money. Every key is namespaced with the configured prefix.
 */
@Injectable()
export class RedisService implements OnModuleInit, OnModuleDestroy {
  readonly client: Redis;
  private readonly prefix: string;

  constructor(
    private readonly config: AppConfig,
    private readonly logger: PinoLogger,
  ) {
    this.logger.setContext(RedisService.name);
    this.prefix = config.redis.keyPrefix;
    this.client = new Redis(config.redis.url, {
      lazyConnect: true,
      maxRetriesPerRequest: 3,
      enableReadyCheck: true,
      // Exponential backoff capped at 2s; never give up reconnecting.
      retryStrategy: (times) => Math.min(times * 200, 2_000),
    });
    this.client.on('error', (err) => this.logger.error({ err }, 'redis error'));
    this.client.on('reconnecting', () => this.logger.warn('redis reconnecting'));
  }

  async onModuleInit(): Promise<void> {
    await this.client.connect();
    this.logger.info('redis connected');
  }

  async onModuleDestroy(): Promise<void> {
    await this.client.quit().catch(() => this.client.disconnect());
  }

  /** Builds a namespaced key: `<prefix>:<parts...>`. */
  key(...parts: readonly (string | number)[]): string {
    return [this.prefix, ...parts].join(':');
  }

  async ping(): Promise<void> {
    const reply = await this.client.ping();
    if (reply !== 'PONG') throw new Error(`unexpected PING reply: ${String(reply)}`);
  }

  /**
   * Runs `fn` while holding a distributed lock. Used to serialise operations
   * per user/call across API replicas (e.g. "start call for user X").
   * The lock auto-expires after `ttlMs` so a crashed holder cannot deadlock.
   */
  async withLock<T>(
    name: string,
    fn: () => Promise<T>,
    options: { ttlMs?: number; waitMs?: number; retryDelayMs?: number } = {},
  ): Promise<T> {
    const { ttlMs = 10_000, waitMs = 2_000, retryDelayMs = 50 } = options;
    const key = this.key('lock', name);
    const token = randomUUID();
    const deadline = Date.now() + waitMs;

    for (;;) {
      const acquired = await this.client.set(key, token, 'PX', ttlMs, 'NX');
      if (acquired === 'OK') break;
      if (Date.now() >= deadline) throw new LockNotAcquiredError(key);
      await new Promise((r) => setTimeout(r, retryDelayMs));
    }

    try {
      return await fn();
    } finally {
      await this.client.eval(RELEASE_LOCK_SCRIPT, 1, key, token).catch((err: unknown) => {
        this.logger.warn({ err, key }, 'failed to release lock (will expire)');
      });
    }
  }
}
