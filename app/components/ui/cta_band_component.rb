# frozen_string_literal: true

module Ui
  class CtaBandComponent < ApplicationComponent
    def initialize(title:, description: nil, href: nil, label: nil)
      super()
      @title = title
      @description = description
      @href = href
      @label = label
    end
  end
end
