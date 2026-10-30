# frozen_string_literal: true

class TeamMember < ApplicationRecord
  belongs_to :athlete

  has_one_attached :photo do |attachable|
    attachable.variant :web, resize_to_limit: [600, 800], preprocessed: true
  end

  validates :role, presence: true
  validates :athlete_id, uniqueness: true
  validates :rank, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :photo, attached: true,
                    content_type: %i[jpg png webp],
                    size: { less_than: 1.megabyte }

  translates :role

  delegate :name, to: :athlete, allow_nil: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[rank]
  end
end
