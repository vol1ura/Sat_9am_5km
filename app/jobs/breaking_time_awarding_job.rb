# frozen_string_literal: true

class BreakingTimeAwardingJob < ApplicationJob
  queue_as :default

  EXPIRATION_PERIOD = 3 # In months

  def perform
    expire_badges
    [true, false].each do |male|
      award_badges(
        Badge.breaking_kind.where("(info->'male')::boolean = ?", male).order(Arel.sql("info->'min'")),
        male: male
      )
    end
  end

  private

  def expire_badges
    Badge.breaking_kind.each do |badge|
      accomplished_athlete_ids =
        Result
          .joins(:activity, athlete: :trophies)
          .where(activity: { date: EXPIRATION_PERIOD.months.ago.. })
          .where(total_time: ...minutes_threshold(badge.info['min']))
          .where(athlete: { trophies: { badge: badge } }).select(:athlete_id)
      Trophy.where(badge: badge).where.not(athlete_id: accomplished_athlete_ids).destroy_all
    end
  end

  # rubocop:disable Metrics/MethodLength
  def award_badges(badges, male:)
    badges.each do |badge|
      time_threshold = badge.info['min']
      prev_badges = badges.where("(info->'min')::integer < ?", time_threshold)
      next_badges = badges.where("(info->'min')::integer > ?", time_threshold)
      Result
        .joins(:activity, :athlete)
        .where(activity: { date: EXPIRATION_PERIOD.months.ago.. })
        .where(total_time: minutes_threshold(prev_badges.last&.info&.dig('min'))...minutes_threshold(time_threshold))
        .where(athlete: { male: male })
        .order(:date)
        .select(:athlete_id, :date)
        .each do |res|
          next if Trophy.exists?(athlete_id: res.athlete_id, badge: prev_badges)

          trophy = Trophy.find_or_initialize_by(athlete_id: res.athlete_id, badge: badge)
          trophy.date = res[:date]
          trophy.transaction do
            Trophy.where(athlete_id: res.athlete_id, badge: next_badges).delete_all
            trophy.save!
          end
        end
    end
  end
  # rubocop:enable Metrics/MethodLength

  # Threshold time. It is 00:00:00 for the first interval.
  def minutes_threshold(minutes)
    Result.total_time(minutes.presence || 0, 0)
  end
end
