# frozen_string_literal: true

class ApplicationService
  extend Dry::Initializer

  def self.call(...) = new(...).call
end
