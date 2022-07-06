# frozen_string_literal: true

class Event < ApplicationRecord
  has_many :activities, dependent: :destroy

  validates :name, :code_name, :town, :place, presence: true
  validates :code_name, uniqueness: true, format: { with: /\A[a-z_]+\z/ } # rubocop:disable Rails/UniqueValidationWithoutIndex
end
