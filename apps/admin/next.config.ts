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
  // Dev-only: lets HMR work when the console is opened via 127.0.0.1.
  allowedDevOrigins: ['127.0.0.1', 'localhost'],
};

export default nextConfig;
