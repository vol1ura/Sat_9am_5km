# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :clubs, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :activities, through: :events

  validates :code, presence: true, uniqueness: true

  def name
    I18n.t("country.#{code}")
  end
end
