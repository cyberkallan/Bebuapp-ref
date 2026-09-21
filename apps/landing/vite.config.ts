import { resolve } from 'node:path';

import { defineConfig } from 'vite';

export default defineConfig({
  // Deployed at the domain root (ayushaura.in). Change if hosted in a subfolder.
  base: '/',
  build: {
    rollupOptions: {
      input: {
        main: resolve(import.meta.dirname, 'index.html'),
        download: resolve(import.meta.dirname, 'download.html'),
      },
    },
    target: 'es2020',
    cssMinify: true,
    assetsInlineLimit: 8192,
  },
});
