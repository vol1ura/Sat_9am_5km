# frozen_string_literal: true

module Ui
  class IconButtonComponent < ApplicationComponent
    TONES = {
      default: 'text-ink-muted hover:bg-accent-subtle hover:text-ink',
      inverse: 'text-white/70 hover:bg-white/10 hover:text-white',
    }.freeze

    def initialize(icon:, label:, tone: :default, **html_options)
      super()
      @icon = icon
      @label = label
      @tone = tone
      @html_options = html_options
    end

    def call
      classes = [
        'inline-flex size-10 items-center justify-center rounded-md leading-none',
        TONES.fetch(@tone, TONES[:default]),
        @html_options[:class],
      ].compact.join(' ')

      opts = @html_options.except(:class, :aria).merge(
        type: 'button',
        class: classes,
        aria: { label: @label }.merge(@html_options.fetch(:aria, {})),
      )

      tag.button(**opts) do
        tag.i(class: "fa-solid fa-#{@icon}", aria: { hidden: true })
      end
    end
  end
end
