# frozen_string_literal: true

module Ui
  class PageSubnavComponent < ApplicationComponent
    def initialize(items:, aria_label:, margin_class: 'mb-6')
      super()
      @items = items
      @aria_label = aria_label
      @margin_class = margin_class
    end
  end
end
