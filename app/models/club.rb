# frozen_string_literal: true

class Club < ApplicationRecord
  belongs_to :country
  has_many :athletes, dependent: :nullify

  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [150, 150], preprocessed: true
  end

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name country_id]
  end
end
