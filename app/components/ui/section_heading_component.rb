# frozen_string_literal: true

module Ui
  class SectionHeadingComponent < ApplicationComponent
    def initialize(title:, kicker: nil, variant: :default, heading_tag: :h2)
      super()
      @title = title
      @kicker = kicker
      @variant = variant.to_sym
      @heading_tag = heading_tag
    end

    def title_content
      case @variant
      when :gradient
        tag.span @title, class: 'text-gradient-brand'
      else
        @title
      end
    end
  end
end
