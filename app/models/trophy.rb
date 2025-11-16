# frozen_string_literal: true

class Trophy < ApplicationRecord
  PARTICIPATING_KINDS = %w[participating home_participating tourist].freeze

  belongs_to :badge
  belongs_to :athlete

  validates :athlete_id, uniqueness: { scope: :badge_id }
  validate :threshold_awards_uniqueness

  store_accessor :info, :data

  private

  def threshold_awards_uniqueness
    return if badge_id.nil? || athlete_id.nil? || PARTICIPATING_KINDS.exclude?(badge.kind)

    other_trophies =
      athlete.trophies.excluding(self).where(badge: Badge.dataset_of(kind: badge.kind, type: badge.info['type']))
    errors.add(:athlete, :more_than_one_trophy) if other_trophies.exists?
  end
end
