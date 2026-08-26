# frozen_string_literal: true

module Ui
  class StatShowcaseComponent < ApplicationComponent
    def initialize(title:, stats:)
      super()
      @title = title
      @stats = stats
    end
  end
end
