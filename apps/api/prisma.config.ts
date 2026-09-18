import { defineConfig } from 'prisma/config';

import { loadRootEnv } from './src/config/load-env.js';

loadRootEnv();

const databaseUrl = process.env['PRISMA_DATABASE_URL'] ?? process.env['DATABASE_URL'];
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
