# frozen_string_literal: true

module Ui
  class BadgeComponent < ApplicationComponent
    VARIANTS = {
      default: 'bg-accent-subtle text-accent',
      brand: 'bg-brand-fill/10 text-brand',
      success: 'bg-success-subtle text-success',
      danger: 'bg-danger-subtle text-danger',
      info: 'bg-info-subtle text-info',
    }.freeze

    def initialize(variant: :default, label: nil, **html_options)
      super()
      @variant = variant
      @label = label
      @html_options = html_options
    end

    def call
      classes = [
        'inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium',
        VARIANTS[@variant],
        @html_options[:class],
      ].compact.join(' ')

      content_tag :span, badge_body, **@html_options.except(:class), class: classes
    end

    private

    def badge_body
      return @label if @label.present?
      return content if content?

      nil
    end
  end
end
