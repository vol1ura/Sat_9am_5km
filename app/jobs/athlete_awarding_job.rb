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
  SKIP_EVENT_IDS = [4].freeze

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
      events_count =
        results
        .joins(activity: :event)
        .where.not(activity: { event_id: SKIP_EVENT_IDS })
        .select('events.id').distinct.count
      athlete.award_by Trophy.new(badge_id: 20, date: activity_date) if events_count >= 5
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
      events_count =
        volunteering
        .joins(activity: :event)
        .where.not(activity: { event_id: SKIP_EVENT_IDS })
        .select('events.id').distinct.count
      volunteer.athlete.award_by Trophy.new(badge_id: 19, date: activity_date) if events_count >= 5
      volunteer.athlete.save!
    end
  end

  def activity_date
    @activity_date ||= @activity.date
  end
end
