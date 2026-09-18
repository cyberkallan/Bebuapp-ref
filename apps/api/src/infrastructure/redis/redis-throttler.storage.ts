import { Injectable } from '@nestjs/common';
import type { ThrottlerStorage } from '@nestjs/throttler';

import { RedisService } from './redis.service.js';

type ThrottlerStorageRecord = Awaited<ReturnType<ThrottlerStorage['increment']>>;

/**
 * Atomic fixed-window counter with optional block period.
 * KEYS[1] hits key, KEYS[2] block key
 * ARGV[1] ttl ms, ARGV[2] limit, ARGV[3] block duration ms
 * Returns { totalHits, hitsTtlMs, isBlocked, blockTtlMs }.
 */
const INCREMENT_SCRIPT = `
local blockTtl = redis.call("PTTL", KEYS[2])
if blockTtl > 0 then
  return { tonumber(redis.call("GET", KEYS[1]) or "0"), redis.call("PTTL", KEYS[1]), 1, blockTtl }
end
local hits = redis.call("INCR", KEYS[1])
if hits == 1 then
  redis.call("PEXPIRE", KEYS[1], ARGV[1])
end
local ttl = redis.call("PTTL", KEYS[1])
if ttl < 0 then
  redis.call("PEXPIRE", KEYS[1], ARGV[1])
  ttl = tonumber(ARGV[1])
end
local limit = tonumber(ARGV[2])
local blockDuration = tonumber(ARGV[3])
if hits > limit and blockDuration > 0 then
  redis.call("SET", KEYS[2], "1", "PX", blockDuration)
  return { hits, ttl, 1, blockDuration }
end
return { hits, ttl, 0, 0 }
`;

/**
 * Redis-backed storage for @nestjs/throttler so limits are shared across all
 * API replicas (the default in-memory storage is per-process).
 */
@Injectable()
export class RedisThrottlerStorage implements ThrottlerStorage {
  constructor(private readonly redis: RedisService) {}

  async increment(
    key: string,
    ttl: number,
    limit: number,
    blockDuration: number,
    throttlerName: string,
  ): Promise<ThrottlerStorageRecord> {
    const hitsKey = this.redis.key('ratelimit', throttlerName, key);
    const blockKey = `${hitsKey}:blocked`;

    const result = (await this.redis.client.eval(
      INCREMENT_SCRIPT,
      2,
      hitsKey,
      blockKey,
      String(ttl),
      String(limit),
      String(blockDuration),
    )) as [number, number, number, number];

    const [totalHits, hitsTtlMs, blocked, blockTtlMs] = result;
    return {
      totalHits,
      timeToExpire: Math.max(0, Math.ceil(hitsTtlMs / 1000)),
      isBlocked: blocked === 1,
      timeToBlockExpire: Math.max(0, Math.ceil(blockTtlMs / 1000)),
    };
  }
}
