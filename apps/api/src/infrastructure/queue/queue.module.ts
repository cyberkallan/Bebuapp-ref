import { BullModule } from '@nestjs/bullmq';
import { Global, Module } from '@nestjs/common';

import { AppConfig } from '../../config/app-config.js';
import { DEFAULT_JOB_OPTIONS, QueueName } from './queue.constants.js';

/**
 * Registers the shared BullMQ connection and every named queue. Feature
 * modules inject queues with `@InjectQueue(QueueName.X)` and define
 * processors with `@Processor(QueueName.X)`. Workers can be disabled on
 * API-only replicas via QUEUE_WORKERS_ENABLED.
 */
@Global()
@Module({
  imports: [
    BullModule.forRootAsync({
      inject: [AppConfig],
      useFactory: (config: AppConfig) => {
        const url = new URL(config.redis.url);
        return {
          connection: {
            host: url.hostname,
            port: Number(url.port || 6379),
            username: url.username || undefined,
            password: url.password || undefined,
            db: url.pathname ? Number(url.pathname.slice(1) || 0) : 0,
            tls: url.protocol === 'rediss:' ? {} : undefined,
            // BullMQ requires blocking commands to never time out.
            maxRetriesPerRequest: null,
          },
          prefix: `${config.redis.keyPrefix}:bull`,
          defaultJobOptions: DEFAULT_JOB_OPTIONS,
        };
      },
    }),
    ...Object.values(QueueName).map((name) => BullModule.registerQueue({ name })),
  ],
  exports: [BullModule],
})
export class QueueModule {}
