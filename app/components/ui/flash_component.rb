# frozen_string_literal: true

module Ui
  class FlashComponent < ApplicationComponent
    def initialize(message:, type: :notice)
      super()
      @message = message
      @type = type
    end

    def call
      variant =
        if @type == :alert
          'bg-danger-subtle text-danger border-danger/20'
        else
          'bg-success-subtle text-success border-success/20'
        end
      icon = @type == :alert ? 'triangle-exclamation' : 'circle-check'
      klass = "mx-auto mb-4 flex max-w-3xl items-center gap-2 rounded-lg border px-4 py-3 #{variant}"

      content_tag :div, class: klass, role: 'alert' do
        safe_join([content_tag(:i, nil, class: "fa-solid fa-#{icon}"), content_tag(:span, @message)])
      end
    end
  end
end
