# frozen_string_literal: true

module Ui
  class ModalComponent < ApplicationComponent
    renders_one :title

    def initialize(id:, size: :md)
      super()
      @id = id
      @size = size
    end

    def size_class
      { sm: 'max-w-sm', md: 'max-w-lg', lg: 'max-w-2xl' }[@size]
    end
  end
end
