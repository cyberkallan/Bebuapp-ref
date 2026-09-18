import path from 'node:path';

import { defineConfig } from 'vitest/config';

export default defineConfig({
  resolve: {
    alias: {
      '@': path.resolve(import.meta.dirname, 'src'),
      // `server-only` throws when imported outside a React Server Components
      // environment; tests exercise the same modules in plain Node.
      'server-only': path.resolve(import.meta.dirname, 'test/server-only.stub.ts'),
    },
  },
  test: {
    include: ['src/**/*.test.ts'],
    environment: 'node',
    clearMocks: true,
  },
});
