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

  def perform(activity)
    return unless activity.published

    process_runners(activity)
    process_volunteers(activity)
  end

  private

  def process_runners(activity)
    activity.athletes.each do |athlete|
      runs_count = athlete.results.joins(:activity).where(activity: { published: true, date: ..activity.date }).size
      RUNNER_BADGES.each do |badge|
        next if runs_count < badge[:threshold]

        athlete.award_by Trophy.new(badge_id: badge[:id], date: activity.date)
        athlete.save!
      end
    end
  end

  def process_volunteers(activity)
    activity.volunteers.each do |volunteer|
      volunteering_count = volunteer.athlete.volunteering.where(activity: { date: ..activity.date }).size
      VOLUNTEERING_BADGES.each do |badge|
        next if volunteering_count < badge[:threshold]

        volunteer.athlete.award_by Trophy.new(badge_id: badge[:id], date: activity.date)
        volunteer.athlete.save!
      end
    end
  end
end
