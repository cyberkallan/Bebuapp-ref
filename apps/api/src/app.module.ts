import { Module } from '@nestjs/common';
import { APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';
import { ThrottlerModule } from '@nestjs/throttler';
import { LoggerModule } from 'nestjs-pino';

import { AppController } from './app.controller.js';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter.js';
import { ensureRequestId } from './common/utils/request-context.js';
import { AppConfig } from './config/app-config.js';
import { ConfigModule } from './config/config.module.js';
import { PrismaModule } from './infrastructure/database/prisma.module.js';
import { FirebaseModule } from './infrastructure/firebase/firebase.module.js';
import { HttpMetricsInterceptor } from './infrastructure/metrics/http-metrics.interceptor.js';
import { MetricsModule } from './infrastructure/metrics/metrics.module.js';
import { QueueModule } from './infrastructure/queue/queue.module.js';
import { RedisThrottlerStorage } from './infrastructure/redis/redis-throttler.storage.js';
import { RedisModule } from './infrastructure/redis/redis.module.js';
import { AdminModule } from './modules/admin/admin.module.js';
import { AgoraModule } from './modules/agora/agora.module.js';
import { AnalyticsModule } from './modules/analytics/analytics.module.js';
import { AuthModule } from './modules/auth/auth.module.js';
import { CallersModule } from './modules/callers/callers.module.js';
import { CallsModule } from './modules/calls/calls.module.js';
import { HealthModule } from './modules/health/health.module.js';
import { MatchingModule } from './modules/matching/matching.module.js';
import { ModerationModule } from './modules/moderation/moderation.module.js';
import { NotificationsModule } from './modules/notifications/notifications.module.js';
import { PaymentsModule } from './modules/payments/payments.module.js';
import { ReengagementModule } from './modules/reengagement/reengagement.module.js';
import { TenantsModule } from './modules/tenants/tenants.module.js';
import { UsersModule } from './modules/users/users.module.js';
import { WalletModule } from './modules/wallet/wallet.module.js';

/** Header names whose values must never appear in logs. */
const REDACTED_PATHS = [
  'req.headers.authorization',
  'req.headers.cookie',
  'req.headers["x-api-key"]',
  'res.headers["set-cookie"]',
];

/**
 * Composition root of the modular monolith. Infrastructure modules are
 * global; feature modules import only what they need so that any of them
 * can later be lifted into its own service.
 */
@Module({
  imports: [
    ConfigModule.forRoot(),
    LoggerModule.forRootAsync({
      inject: [AppConfig],
      useFactory: (config: AppConfig) => ({
        pinoHttp: {
          level: config.logging.level,
          genReqId: ensureRequestId,
          redact: { paths: REDACTED_PATHS, censor: '[REDACTED]' },
          autoLogging: { ignore: (req) => (req.url ?? '').startsWith('/health') || req.url === '/metrics' },
          customProps: (req) => ({
            tenantId: (req as { tenant?: { id: string } }).tenant?.id,
          }),
          serializers: {
            req: (req: { id: string; method: string; url: string; remoteAddress?: string }) => ({
              id: req.id,
              method: req.method,
              url: req.url,
              remoteAddress: req.remoteAddress,
            }),
          },
          transport: config.logging.pretty
            ? { target: 'pino-pretty', options: { colorize: true, singleLine: true, translateTime: 'SYS:HH:MM:ss.l' } }
            : undefined,
        },
      }),
    }),
    ThrottlerModule.forRootAsync({
      imports: [RedisModule],
      inject: [AppConfig, RedisThrottlerStorage],
      useFactory: (config: AppConfig, storage: RedisThrottlerStorage) => ({
        throttlers: [
          { name: 'global', ttl: config.rateLimit.ttlSeconds * 1000, limit: config.rateLimit.max },
        ],
        storage,
        // Behind a proxy, express populates req.ips from X-Forwarded-For when trust proxy is set.
        getTracker: (req: { ips?: string[]; ip?: string }) => req.ips?.[0] ?? req.ip ?? 'unknown',
      }),
    }),

    // Infrastructure
    PrismaModule,
    RedisModule,
    QueueModule,
    FirebaseModule,
    MetricsModule,

    // Platform
    HealthModule,
    AuthModule,
    TenantsModule,
    UsersModule,

    // Domain
    CallersModule,
    WalletModule,
    PaymentsModule,
    CallsModule,
    AgoraModule,
    NotificationsModule,
    ReengagementModule,
    MatchingModule,
    ModerationModule,
    AdminModule,
    AnalyticsModule,
  ],
  controllers: [AppController],
  providers: [
    { provide: APP_FILTER, useClass: AllExceptionsFilter },
    { provide: APP_INTERCEPTOR, useExisting: HttpMetricsInterceptor },
  ],
})
export class AppModule {}
