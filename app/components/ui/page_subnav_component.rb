# frozen_string_literal: true

module Ui
  class PageSubnavComponent < ApplicationComponent
    def initialize(items:, aria_label:, variant: :default)
      super()
      @items = items
      @aria_label = aria_label
      @variant = variant.to_sym
    end

    def nav_classes
      classes = [
        'page-subnav mb-6 border-b border-line bg-surface/95 backdrop-blur-sm',
        'lg:sticky lg:top-14 lg:z-20',
      ]
      classes << '-mt-6' unless embedded?
      classes.join(' ')
    end

    def embedded?
      @variant == :embedded
    end
  end
end
