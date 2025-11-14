module.exports = {
  extends: ['stylelint-config-standard-scss'],
  rules: {
    // Allow nested selectors for BEM-like patterns
    'selector-class-pattern': null,
    // Relax spacing rules for existing codebase
    'rule-empty-line-before': null,
    // Allow @extend with regular selectors
    'scss/at-extend-no-missing-placeholder': null,
    // Relax specificity rules
    'no-descending-specificity': null,
  },
};
