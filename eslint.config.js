export default [
  {
    files: ['app/javascript/**/*.js'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        window: 'readonly',
        document: 'readonly',
        navigator: 'readonly',
        console: 'readonly'
      },
    },
    rules: {
      'indent': ['error', 2],
      'quotes': ['error', 'single'],
      'semi': ['error', 'always'],
      'no-unused-vars': ['error', {
        'argsIgnorePattern': '^_',
      }],
      'no-const-assign': 'error',
      'no-redeclare': 'error',
      'no-var': 'error',
      'prefer-const': 'error',
      'eqeqeq': ['error', 'always'],
      'no-multiple-empty-lines': ['error', { max: 1, maxEOF: 0 }],
      'arrow-spacing': 'error',
      'keyword-spacing': 'error',
      'space-infix-ops': 'error',
    },
  },
];
