# frozen_string_literal: true

module Ui
  class ButtonComponent < ApplicationComponent
    VARIANTS = {
      primary: 'bg-accent text-accent-fg hover:opacity-90',
      secondary: 'bg-surface-elevated text-ink border border-line hover:bg-accent-subtle',
      ghost: 'bg-transparent text-ink hover:bg-accent-subtle',
      brand: 'bg-brand-fill text-brand-fg hover:opacity-90',
      danger: 'bg-danger text-danger-fg hover:opacity-90',
    }.freeze

    SIZES = {
      sm: 'px-3 py-1.5 text-sm',
      md: 'px-4 py-2 text-sm',
      lg: 'px-6 py-3 text-base',
    }.freeze

    def initialize(variant: :primary, size: :md, href: nil, **html_options)
      super()
      @variant = variant
      @size = size
      @href = href
      @type = html_options.delete(:type) || 'button'
      @label = html_options.delete(:label)
      @html_options = html_options
    end

    def call
      classes = [
        'inline-flex items-center justify-center gap-2 rounded-md font-medium',
        'transition-opacity duration-200 focus-visible:outline-none',
        'disabled:cursor-not-allowed disabled:opacity-50',
        VARIANTS[@variant],
        SIZES[@size],
        @html_options[:class],
      ].compact.join(' ')

      opts = @html_options.except(:class).merge(class: classes)
      body = button_body

      if @href
        link_to body, @href, **opts
      else
        content_tag :button, body, type: @type, **opts
      end
    end

    private

    def button_body
      return @label if @label.present?
      return content if content?

      nil
    end
  end
end
