import 'reflect-metadata';

import { type INestApplication, VersioningType } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import type { NestExpressApplication } from '@nestjs/platform-express';
import { type ApiErrorBody, ErrorCode } from '@bebu/shared';
import type { Express, Request, Response } from 'express';
import helmet from 'helmet';
import { Logger, PinoLogger } from 'nestjs-pino';

import { AppModule } from './app.module.js';
import { ensureRequestId } from './common/utils/request-context.js';
import { AppConfig } from './config/app-config.js';

/**
 * Applies process-wide HTTP hardening. Exported so e2e tests boot the exact
 * same pipeline as production.
 */
export function configureApp(app: NestExpressApplication): INestApplication {
  const config = app.get(AppConfig);

  app.useLogger(app.get(Logger));
  app.enableShutdownHooks();
  app.disable('x-powered-by');
  app.set('trust proxy', config.http.trustProxyHops);

  app.use(
    helmet({
      // API only: no HTML is served, so a strict CSP is safe.
      contentSecurityPolicy: { directives: { defaultSrc: ["'none'"], frameAncestors: ["'none'"] } },
      crossOriginResourcePolicy: { policy: 'same-site' },
      hsts: config.isProduction ? { maxAge: 31_536_000, includeSubDomains: true, preload: true } : false,
    }),
  );

  app.enableCors({
    origin: (origin, callback) => {
      // Mobile apps send no Origin; browsers must be on the allow-list.
      if (!origin || config.http.corsOrigins.includes(origin)) return callback(null, true);
      return callback(null, false);
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Authorization', 'Content-Type', 'X-Tenant-Key', 'X-Request-Id', 'Idempotency-Key'],
    exposedHeaders: ['X-Request-Id'],
    maxAge: 600,
  });

  app.setGlobalPrefix('api', { exclude: ['health', 'health/(.*)', 'metrics', '/'] });
  app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' });

  return app;
}

/**
 * Nest only installs its not-found handler under the global prefix; anything
 * else would fall through to Express's HTML 404. Call after `app.init()` so
 * every unknown path gets the same JSON error envelope.
 */
export function registerFallbackNotFound(app: INestApplication): void {
  const express = app.getHttpAdapter().getInstance() as Express;
  express.use((req: Request, res: Response) => {
    const requestId = ensureRequestId(req, res);
    const body: ApiErrorBody = {
      statusCode: 404,
      code: ErrorCode.NOT_FOUND,
      message: `Cannot ${req.method} ${req.path}`,
      requestId,
    };
    res.status(404).json(body);
  });
}

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bufferLogs: true,
    rawBody: true, // needed later for payment webhook signature verification
  });
  configureApp(app);
  await app.init();
  registerFallbackNotFound(app);

  const config = app.get(AppConfig);
  const logger = await app.resolve(PinoLogger);
  logger.setContext('Bootstrap');

  await app.listen(config.http.port, config.http.host);
  logger.info(
    { port: config.http.port, host: config.http.host, env: config.nodeEnv, authMode: config.auth.mode },
    'bebu api listening',
  );
}

const isDirectRun =
  process.argv[1] !== undefined &&
  (process.argv[1].endsWith('/main.js') || process.argv[1].endsWith('/main.ts'));
if (isDirectRun) {
  bootstrap().catch((err: unknown) => {
    console.error(err instanceof Error ? err.message : err);
    process.exit(1);
  });
}
