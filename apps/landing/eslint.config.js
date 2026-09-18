import { nodeTypeScriptConfig } from '@bebu/config/eslint.base';
import globals from 'globals';

export default [
  ...nodeTypeScriptConfig({ tsconfigRootDir: import.meta.dirname, typeChecked: false }),
  {
    files: ['scripts/**/*.mjs'],
    languageOptions: { globals: { ...globals.node } },
  },
  {
    files: ['src/**/*.ts'],
    languageOptions: { globals: { ...globals.browser } },
  },
];
