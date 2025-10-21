# frozen_string_literal: true

# Award by funrun or jubilee badge on published activity
class FunrunAwardingJob < ApplicationJob
  queue_as :default

  def perform(activity_id, badge_id)
    activity = Activity.published.find activity_id
    badge = Badge.find badge_id
    return unless badge.funrun_kind? || badge.jubilee_participating_kind?
    return if badge.funrun_kind? && activity.date != badge.received_date
    return if badge.jubilee_participating_kind? && activity.number != badge.info['threshold']

    activity.participants.where.not(id: badge.trophies.select(:athlete_id)).find_each do |athlete|
      athlete.trophies.create badge: badge, date: activity.date
      next if athlete.valid?

      Rollbar.error(
        "Awarding by '#{badge.kind}' badge failed",
        errors: athlete.errors.inspect,
        athlete_id: athlete.id,
        badge_id: badge.id,
      )
    end
  end
end
