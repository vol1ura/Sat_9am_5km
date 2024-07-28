# frozen_string_literal: true

class Newsletter < ApplicationRecord
  validates :body, presence: true
end
