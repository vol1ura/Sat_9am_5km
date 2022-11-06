# frozen_string_literal: true

class AthleteAwardingJob < ApplicationJob
  queue_as :default

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
      participating_badges_dataset(type: 'athlete').each do |badge|
        next if results.size < badge.info['threshold']

        athlete.award_by Trophy.new(badge: badge, date: activity_date)
      end
      events_count = results.joins(activity: :event).select('events.id').distinct.count
      tourist_badge = Badge.tourist_kind.where("info ->> 'type' = 'athlete'").take
      if events_count >= tourist_badge.info['threshold']
        athlete.award_by Trophy.new(badge: tourist_badge, date: activity_date)
      end
      # record_badge = Trophy.joins(:activity).where(badge_id: RECORD_BADGES.dig(:male, :id), activity: { event_id: @activity.event_id })
      # Result.joins(:athlete).order(:total_time).where(athlete: { male: true }).first
      athlete.save!
    end
  end

  def process_volunteers
    @activity.volunteers.each do |volunteer|
      volunteering = volunteer.athlete.volunteering.where(activity: { date: ..activity_date })
      participating_badges_dataset(type: 'volunteer').each do |badge|
        next if volunteering.size < badge.info['threshold']

        volunteer.athlete.award_by Trophy.new(badge: badge, date: activity_date)
      end
      events_count = volunteering.joins(activity: :event).select('events.id').distinct.count
      tourist_badge = Badge.tourist_kind.where("info ->> 'type' = 'volunteer'").take
      if events_count >= tourist_badge.info['threshold']
        volunteer.athlete.award_by Trophy.new(badge: tourist_badge, date: activity_date)
      end
      volunteer.athlete.save!
    end
  end

  def participating_badges_dataset(type:)
    Badge.participating_kind.where("info ->> 'type' = ?", type).order(Arel.sql("info -> 'threshold'"))
  end

  def activity_date
    @activity_date ||= @activity.date
  end
end
