# frozen_string_literal: true

class BreakingTimeAwardingJob < ApplicationJob
  queue_as :default

  EXPIRATION_PERIOD = 3.months

  def perform(activity_id = nil)
    expire_badges

    [true, false].each do |male|
      award_badges(
        Badge.breaking_kind.where("(info->'male')::boolean = ?", male).order(Arel.sql("info->'min'")),
        activity_id:,
        male:,
      )
    end
  end

  private

  def expire_badges
    Badge.breaking_kind.each do |badge|
      accomplished_athlete_ids =
        results_dataset
          .joins(athlete: :trophies)
          .where(total_time: ...minutes_threshold(badge.info['min']))
          .where(athlete: { trophies: { badge: } })
          .select(:athlete_id)
      Trophy.where(badge:).where.not(athlete_id: accomplished_athlete_ids).destroy_all
    end
  end

  # rubocop:disable Metrics/MethodLength
  def award_badges(badges, activity_id:, male:)
    badges.each do |badge|
      time_threshold = badge.info['min']
      prev_badges = badges.where("(info->'min')::integer < ?", time_threshold)
      next_badges = badges.where("(info->'min')::integer > ?", time_threshold)
      results_dataset(activity_id:)
        .joins(:athlete)
        .where(total_time: minutes_threshold(prev_badges.last&.info&.dig('min'))...minutes_threshold(time_threshold))
        .where(athlete: { male: })
        .order(:date)
        .select(:athlete_id, :date)
        .each do |res|
          next if Trophy.exists?(athlete_id: res[:athlete_id], badge: prev_badges)

          trophy = Trophy.find_or_initialize_by(athlete_id: res[:athlete_id], badge: badge)
          trophy.date = res[:date]
          trophy.transaction do
            Trophy.where(athlete_id: res[:athlete_id], badge: next_badges).delete_all
            trophy.save!
          end
        end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def results_dataset(activity_id: nil)
    ds = Result.published.where(activity: { date: EXPIRATION_PERIOD.ago.. })
    ds = ds.where(activity_id:) if activity_id
    ds
  end

  # Threshold time. It is 00:00:00 for the first interval.
  def minutes_threshold(minutes)
    Result.total_time(minutes || 0, 0)
  end
end
