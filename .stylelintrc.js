export default {
  customSyntax: 'postcss-scss',
  plugins: [
    '@stylistic/stylelint-plugin',
  ],
  rules: {
    '@stylistic/indentation': 2,
    '@stylistic/color-hex-case': 'lower',
    '@stylistic/number-leading-zero': 'always',
    '@stylistic/number-no-trailing-zeros': true,
    '@stylistic/function-whitespace-after': 'always',
    '@stylistic/no-eol-whitespace': true,
    '@stylistic/linebreaks': 'unix',
    '@stylistic/string-quotes': 'double',
    '@stylistic/max-empty-lines': 1,
    // Allow nested selectors for BEM-like patterns
    'selector-class-pattern': null,
    // Relax spacing rules for existing codebase
    'rule-empty-line-before': null,
    // Relax specificity rules
    'no-descending-specificity': null,
    // Disallow single-line styles
    'declaration-block-single-line-max-declarations': 0,
  },
};
