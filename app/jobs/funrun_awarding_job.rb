# frozen_string_literal: true

# Award funrun badge on published activity
class FunrunAwardingJob < ApplicationJob
  queue_as :default

  def perform(activity_id, badge_id)
    activity = Activity.published.find activity_id
    badge = Badge.funrun_kind.find badge_id

    activity.athletes.each do |athlete|
      athlete.award_by Trophy.new(badge: badge, date: activity.date)
      Rollbar.error(athlete.errors.inspect) unless athlete.save
    end

    activity.volunteers.each do |volunteer|
      volunteer.athlete.award_by Trophy.new(badge: badge, date: activity.date)
      Rollbar.error(volunteer.athlete.errors.inspect) unless volunteer.athlete.save
    end
  end
end
