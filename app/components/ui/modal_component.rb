# frozen_string_literal: true

module Ui
  class ModalComponent < ApplicationComponent
    renders_one :title

    def initialize(id:)
      super()
      @id = id
    end
  end
end
