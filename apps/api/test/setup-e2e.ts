import 'reflect-metadata';

import { execSync } from 'node:child_process';

import { loadRootEnv } from '../src/config/load-env.js';

/**
 * Integration tests run against a dedicated database (DATABASE_URL_TEST) and
 * Redis logical db 1 so they can never touch development data. Migrations
 * are applied once per run with `prisma migrate deploy`.
 */
loadRootEnv();

const testDbUrl = process.env['DATABASE_URL_TEST'];
if (!testDbUrl) throw new Error('DATABASE_URL_TEST must be set to run integration tests');

process.env['NODE_ENV'] = 'test';
process.env['DATABASE_URL'] = testDbUrl;
process.env['PRISMA_DATABASE_URL'] = testDbUrl;
process.env['REDIS_URL'] = (process.env['REDIS_URL'] ?? 'redis://127.0.0.1:6379').replace(/\/\d+$/, '') + '/1';
process.env['REDIS_KEY_PREFIX'] = 'bebu:test';
process.env['AUTH_MODE'] = 'dev';
process.env['LOG_LEVEL'] = 'fatal';
process.env['LOG_PRETTY'] = 'false';
process.env['QUEUE_WORKERS_ENABLED'] = 'false';

execSync('pnpm exec prisma migrate deploy', { stdio: 'pipe', env: process.env });
