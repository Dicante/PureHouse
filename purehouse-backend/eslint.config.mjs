// @ts-check
import eslint from '@eslint/js';
import eslintPluginPrettierRecommended from 'eslint-plugin-prettier/recommended';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  {
    ignores: ['eslint.config.mjs'],
  },
  eslint.configs.recommended,
  // Avoid the type-checked config here because it enables many rules that
  // require parserServices (and produce noisy 'error typed value' diagnostics
  // in some editors/IDEs). Use the non-type-checked recommended set.
  ...tseslint.configs.recommended,
  eslintPluginPrettierRecommended,
  {
    languageOptions: {
      globals: {
        ...globals.node,
        ...globals.jest,
      },
      sourceType: 'commonjs',
      parserOptions: {
        projectService: true,
        // import.meta.dirname is non-standard; use URL to get the directory
        // of this config file which is compatible in Node ESM.
        tsconfigRootDir: new URL('.', import.meta.url).pathname,
      },
    },
  },
  {
    rules: {
      '@typescript-eslint/no-explicit-any': 'off',
  // These rules are commonly the cause of a large number of noisy
  // editor diagnostics in projects that mix plain JS/older libs with
  // TypeScript. Turn them off to reduce noise; you can re-enable them
  // later if you want stricter type-checked linting.
  '@typescript-eslint/no-unsafe-assignment': 'off',
  '@typescript-eslint/no-unsafe-member-access': 'off',
  '@typescript-eslint/no-unsafe-call': 'off',
  '@typescript-eslint/no-unsafe-return': 'off',
  '@typescript-eslint/no-floating-promises': 'warn',
  '@typescript-eslint/no-unsafe-argument': 'off',
      "prettier/prettier": ["error", { endOfLine: "auto" }],
    },
  },
);
