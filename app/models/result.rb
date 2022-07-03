# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :activity
  belongs_to :athlete, optional: true

  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
end
