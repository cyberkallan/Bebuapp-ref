// Shared ESLint flat-config fragments for all TypeScript packages in the monorepo.
// Consumers spread these into their own `eslint.config.js` and add
// package-specific settings (tsconfig path, ignores, framework rules).
import js from '@eslint/js';
import prettier from 'eslint-config-prettier';
import globals from 'globals';
import tseslint from 'typescript-eslint';

/**
 * Build the base config for a Node/TypeScript package.
 *
 * @param {object} options
 * @param {string} options.tsconfigRootDir  Directory containing the package tsconfig.
 * @param {string[]} [options.ignores]      Extra glob patterns to ignore.
 * @param {boolean} [options.typeChecked]   Enable type-aware rules (slower, stricter).
 */
export function nodeTypeScriptConfig({ tsconfigRootDir, ignores = [], typeChecked = true }) {
  return tseslint.config(
    {
      ignores: ['dist/**', 'coverage/**', 'node_modules/**', '**/*.d.ts', ...ignores],
    },
    js.configs.recommended,
    ...(typeChecked ? tseslint.configs.recommendedTypeChecked : tseslint.configs.recommended),
    ...tseslint.configs.stylistic,
    {
      // Config and tooling files are plain JS/MJS: lint them without type info.
      files: ['**/*.js', '**/*.mjs', '**/*.cjs'],
      ...tseslint.configs.disableTypeChecked,
    },
    {
      files: ['**/*.ts', '**/*.tsx', '**/*.mts', '**/*.cts'],
      languageOptions: {
        ecmaVersion: 2023,
        sourceType: 'module',
        globals: { ...globals.node },
        parserOptions: typeChecked
          ? {
              projectService: true,
              tsconfigRootDir,
            }
          : {},
      },
      rules: {
        // Financial code must never silently swallow rejected promises.
        '@typescript-eslint/no-floating-promises': typeChecked ? 'error' : 'off',
        '@typescript-eslint/no-misused-promises': typeChecked ? 'error' : 'off',
        '@typescript-eslint/no-explicit-any': 'error',
        '@typescript-eslint/explicit-module-boundary-types': 'off',
        '@typescript-eslint/consistent-type-imports': [
          'error',
          { prefer: 'type-imports', fixStyle: 'inline-type-imports' },
        ],
        '@typescript-eslint/no-unused-vars': [
          'error',
          { argsIgnorePattern: '^_', varsIgnorePattern: '^_', caughtErrorsIgnorePattern: '^_' },
        ],
        '@typescript-eslint/consistent-type-definitions': ['error', 'interface'],
        // Nest relies on classes with only decorators / empty constructors.
        '@typescript-eslint/no-extraneous-class': 'off',
        'no-console': ['error', { allow: ['warn', 'error'] }],
        eqeqeq: ['error', 'always'],
        'prefer-const': 'error',
      },
    },
    prettier,
  );
}
