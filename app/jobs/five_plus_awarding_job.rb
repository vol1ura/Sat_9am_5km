# frozen_string_literal: true

class FivePlusAwardingJob < ApplicationJob
  queue_as :low

  def perform(activity_id, with_expiration: false)
    expire_trophies if with_expiration
    activity = Activity.published.find activity_id

    activity.participants.where.not(id: five_plus_badge.trophies.select(:athlete_id)).find_each do |athlete|
      athlete.trophies.create badge: five_plus_badge, date: activity.date if athlete.award_by_five_plus_badge?
      next if athlete.valid?

      Rollbar.error(
        "Awarding by '5+' badge failed",
        errors: athlete.errors.inspect,
        athlete_id: athlete.id,
      )
    end
  end

  private

  def expire_trophies
    Trophy.where(badge: five_plus_badge).includes(:athlete).find_each do |trophy|
      trophy.destroy unless trophy.athlete.award_by_five_plus_badge?
    end
  end

  def five_plus_badge
    @five_plus_badge ||= Badge.five_plus_kind.sole
  end
end
