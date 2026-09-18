import { Global, Module } from '@nestjs/common';

import { RedisThrottlerStorage } from './redis-throttler.storage.js';
import { RedisService } from './redis.service.js';

@Global()
@Module({
  providers: [RedisService, RedisThrottlerStorage],
  exports: [RedisService, RedisThrottlerStorage],
})
export class RedisModule {}
