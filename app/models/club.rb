# frozen_string_literal: true

class Club < ApplicationRecord
  has_many :athletes, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    ['name']
  end
end
