# frozen_string_literal: true

module Ui
  class CardComponent < ApplicationComponent
    renders_one :header
    renders_one :footer

    def initialize(padding: true, hover: false, **html_options)
      super()
      @padding = padding
      @hover = hover
      @html_options = html_options
    end

    def call
      classes = [
        'relative rounded-lg border border-line bg-surface',
        @hover ? 'transition-shadow duration-200 hover:shadow-md' : nil,
        @html_options[:class],
      ].compact.join(' ')

      content_tag :div, **@html_options.except(:class), class: classes do
        safe_join([
          (header if header?),
          content_tag(:div, content, class: (@padding ? 'p-4' : nil)),
          (footer if footer?),
        ].compact)
      end
    end
  end
end
