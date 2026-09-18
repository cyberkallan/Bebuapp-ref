import { existsSync } from 'node:fs';
import path from 'node:path';

import type { NextConfig } from 'next';

// Share the repository-root `.env` with the admin server so one file
// configures every app locally. Existing process variables always win.
for (const file of ['.env', '.env.local']) {
  const candidate = path.resolve(__dirname, '../..', file);
  if (existsSync(candidate)) process.loadEnvFile(candidate);
}

const nextConfig: NextConfig = {
  reactStrictMode: true,
  poweredByHeader: false,
  typedRoutes: true,
};

export default nextConfig;
