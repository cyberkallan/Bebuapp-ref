import { Module } from '@nestjs/common';

import { CallersModule } from '../callers/callers.module.js';

/**
 * Caller discovery and matching. This stage defines the Redis key layout for
 * presence/availability (`presence.keys.ts`). A later stage adds:
 *  - PresenceService: heartbeat endpoints, ONLINE/BUSY/DND transitions,
 *    availability ZSETs per tenant and call type (respecting the shared
 *    caller pool allow-list).
 *  - DiscoveryService: ranked caller lists (online first, rating, price,
 *    language match, recency) with cursor pagination.
 *  - RandomMatchService: atomic "claim an available caller" using
 *    RedisService.withLock to avoid double-booking under concurrency.
 */
@Module({
  imports: [CallersModule],
})
export class MatchingModule {}
