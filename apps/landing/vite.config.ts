import { defineConfig } from 'vite';

export default defineConfig({
  // Deployed at the domain root (ayushaura.in). Change if hosted in a subfolder.
  base: '/',
  build: {
    target: 'es2020',
    cssMinify: true,
    assetsInlineLimit: 8192,
  },
});
