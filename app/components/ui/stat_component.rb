# frozen_string_literal: true

module Ui
  class StatComponent < ApplicationComponent
    def initialize(label:, value:, highlight: false)
      super()
      @label = label
      @value = value
      @highlight = highlight
    end

    def stat_classes
      base = 'block rounded-lg border border-line bg-surface p-4 transition-colors duration-200'
      @highlight ? "#{base} border-accent bg-accent-subtle" : base
    end
  end
end
