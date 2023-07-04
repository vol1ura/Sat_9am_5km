# frozen_string_literal: true

class Club < ApplicationRecord
  has_many :athletes, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
