# frozen_string_literal: true

class AthleteAwardingJob < ApplicationJob
  queue_as :default

  RUNNER_BADGES = [
    { id: 7, threshold: 25 },
    { id: 8, threshold: 50 },
    { id: 9, threshold: 100 }
  ].freeze
  VOLUNTEERING_BADGES = [
    { id: 10, threshold: 25 },
    { id: 11, threshold: 50 },
    { id: 12, threshold: 100 }
  ].freeze
  TOURIST_VOLUNTEER_BADGE = { id: 19, threshold: 5 }.freeze
  TOURIST_RUNNER_BADGE = { id: 20, threshold: 5 }.freeze

  def perform(activity_id)
    @activity = Activity.find activity_id
    return unless @activity.published

    process_runners
    process_volunteers
  end

  private

  def process_runners
    @activity.athletes.each do |athlete|
      results = athlete.results.joins(:activity).where(activity: { published: true, date: ..activity_date })
      RUNNER_BADGES.each do |badge|
        next if results.size < badge[:threshold]

        athlete.award_by Trophy.new(badge_id: badge[:id], date: activity_date)
      end
      events_count = results.joins(activity: :event).select('events.id').distinct.count
      if events_count >= TOURIST_RUNNER_BADGE[:threshold]
        athlete.award_by Trophy.new(badge_id: TOURIST_RUNNER_BADGE[:id], date: activity_date)
      end
      athlete.save!
    end
  end

  def process_volunteers
    @activity.volunteers.each do |volunteer|
      volunteering = volunteer.athlete.volunteering.where(activity: { date: ..activity_date })
      VOLUNTEERING_BADGES.each do |badge|
        next if volunteering.size < badge[:threshold]

        volunteer.athlete.award_by Trophy.new(badge_id: badge[:id], date: activity_date)
      end
      events_count = volunteering.joins(activity: :event).select('events.id').distinct.count
      if events_count >= TOURIST_VOLUNTEER_BADGE[:threshold]
        volunteer.athlete.award_by Trophy.new(badge_id: TOURIST_VOLUNTEER_BADGE[:id], date: activity_date)
      end
      volunteer.athlete.save!
    end
  end

  def activity_date
    @activity_date ||= @activity.date
  end
end
