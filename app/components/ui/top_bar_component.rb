# frozen_string_literal: true

module Ui
  class TopBarComponent < ApplicationComponent
    def initialize
      super
      @current_date = Date.current
    end
  end
end
