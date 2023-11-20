# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :clubs, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :activities, through: :events

  validates :code, presence: true, uniqueness: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[code created_at id updated_at]
  end

  def name
    I18n.t("country.#{code}")
  end
end
