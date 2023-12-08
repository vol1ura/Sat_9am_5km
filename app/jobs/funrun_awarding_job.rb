# frozen_string_literal: true

# Award funrun badge on published activity
class FunrunAwardingJob < ApplicationJob
  queue_as :default

  def perform(activity_id, badge_id)
    activity = Activity.published.find activity_id
    badge = Badge.funrun_kind.find badge_id

    Athlete.where(id: activity.results.select(:athlete_id))
      .or(Athlete.where(id: activity.volunteers.select(:athlete_id)))
      .find_each do |athlete|
        athlete.trophies.create badge: badge, date: activity.date
        Rollbar.error(athlete.errors.inspect) unless athlete.valid?
      end
  end
end
