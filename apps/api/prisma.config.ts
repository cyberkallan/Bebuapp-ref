import { defineConfig } from 'prisma/config';

import { loadRootEnv } from './src/config/load-env.js';

loadRootEnv();

// `prisma generate` (e.g. inside a Docker image build) has no database; the
// placeholder is never dialled because generate does not connect.
const BUILD_PLACEHOLDER_URL = 'postgresql://build:build@127.0.0.1:5432/build';

const databaseUrl =
  process.env['PRISMA_DATABASE_URL'] ??
  process.env['DATABASE_URL'] ??
  (process.env['PRISMA_ALLOW_MISSING_DATABASE_URL'] === '1' ? BUILD_PLACEHOLDER_URL : undefined);
if (!databaseUrl) {
  throw new Error('DATABASE_URL is not set; copy .env.example to .env at the repository root');
}

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: databaseUrl,
  },
});
