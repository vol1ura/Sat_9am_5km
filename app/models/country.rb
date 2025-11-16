# frozen_string_literal: true

class Country < ApplicationRecord
  has_many :clubs, dependent: :destroy
  has_many :events, -> { unscope(:order) }, class_name: 'Event', dependent: :destroy, inverse_of: :country
  has_many :activities, through: :events

  validates :code, presence: true, uniqueness: true

  def self.default = find_by code: 'ru'

  def name = I18n.t "country.#{code}"

  def host = "s95.#{code}"

  def localized(key, **)
    I18n.t(key, locale: I18n.available_locales.include?(code.to_sym) ? code.to_sym : I18n.default_locale, **)
  end
end
