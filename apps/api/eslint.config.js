import { nodeTypeScriptConfig } from '@bebu/config/eslint.base';

export default [
  ...nodeTypeScriptConfig({
    tsconfigRootDir: import.meta.dirname,
    ignores: ['src/generated/**', 'prisma/migrations/**'],
  }),
  {
    // supertest types `response.body` as `any`; asserting on it is the whole
    // point of an e2e test, so the unsafe-* family is noise here.
    files: ['test/**/*.ts', 'src/**/*.spec.ts'],
    rules: {
      '@typescript-eslint/no-unsafe-assignment': 'off',
      '@typescript-eslint/no-unsafe-member-access': 'off',
      '@typescript-eslint/no-unsafe-argument': 'off',
      '@typescript-eslint/no-unsafe-call': 'off',
      '@typescript-eslint/no-unsafe-return': 'off',
    },
  },
];
