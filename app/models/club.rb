# frozen_string_literal: true

class Club < ApplicationRecord
  belongs_to :country
  has_many :athletes, dependent: :nullify

  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [60, 60]
    attachable.variant :web, resize_to_limit: [150, 150], preprocessed: true
  end

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :logo, size: { less_than: 250.kilobytes }, dimension: { width: { in: 150..400 }, height: { in: 150..400 } }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name country_id]
  end
end
