# frozen_string_literal: true

class FullProfileAwardingJob < ApplicationJob
  queue_as :low

  def perform
    expire_badges
    award_athletes
  end

  private

  def badge
    @badge ||= Badge.full_profile_kind.sole
  end

  # athletes with images
  def athletes_dataset
    Athlete.joins(user: :image_attachment)
  end

  def expire_badges
    badge
      .trophies
      .eager_load(:athlete)
      .where(
        'athletes.event_id IS NULL OR athletes.user_id IS NULL OR athletes.id NOT IN (?)',
        athletes_dataset.select(:id),
      )
      .find_each do |trophy|
        trophy.destroy
        Athletes::StatsUpdate.call trophy.athlete
      end
  end

  def award_athletes
    athletes_dataset
      .where.not(id: badge.trophies.select(:athlete_id))
      .where.not(event_id: nil)
      .distinct
      .find_each do |athlete|
        athlete.trophies.create badge: badge, date: Date.current
        if athlete.valid?
          Athletes::StatsUpdate.call athlete
          next
        end

        Rollbar.error(
          "Awarding by 'full_profile' badge failed",
          errors: athlete.errors.inspect,
          athlete_id: athlete.id,
        )
      end
  end
end
