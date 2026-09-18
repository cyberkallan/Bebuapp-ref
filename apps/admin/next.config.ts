import { existsSync } from 'node:fs';
import path from 'node:path';

import type { NextConfig } from 'next';

// Share the repository-root `.env` with the admin server so one file
// configures every app locally. Existing process variables always win.
for (const file of ['.env', '.env.local']) {
  const candidate = path.resolve(__dirname, '../..', file);
  if (existsSync(candidate)) process.loadEnvFile(candidate);
}

// Serve the console under a sub-path (e.g. "/admin" on the production host).
// Empty (default) keeps it at the domain root for local development.
const basePath = (process.env.ADMIN_BASE_PATH ?? '').replace(/\/$/, '');
if (basePath && !basePath.startsWith('/')) {
  throw new Error('ADMIN_BASE_PATH must start with "/" (e.g. /admin)');
}

const nextConfig: NextConfig = {
  reactStrictMode: true,
  poweredByHeader: false,
  typedRoutes: true,
  ...(basePath ? { basePath } : {}),
  // Self-contained server bundle for the Docker image (infra/deploy).
  output: process.env.NEXT_OUTPUT_STANDALONE === '1' ? 'standalone' : undefined,
  outputFileTracingRoot: path.resolve(__dirname, '../..'),
  // Dev-only: lets HMR work when the console is opened via 127.0.0.1.
  allowedDevOrigins: ['127.0.0.1', 'localhost'],
};

export default nextConfig;
