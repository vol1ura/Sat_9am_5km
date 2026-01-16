# frozen_string_literal: true

class BreakingTimeAwardingJob < ApplicationJob
  queue_as :default

  EXPIRATION_PERIOD = 3.months

  def perform(activity_id = nil)
    expire_badges

    Athlete.genders.each_key do |gender|
      award_badges(
        Badge.breaking_kind.where("info->>'gender' = ?", gender).order(Arel.sql("(info->>'sec')::integer")),
        activity_id:,
        gender:,
      )
    end
  end

  private

  def expire_badges
    Badge.breaking_kind.each do |badge|
      accomplished_athlete_ids =
        results_dataset
          .joins(athlete: :trophies)
          .where(total_time: ...badge.info['sec'])
          .where(athlete: { trophies: { badge: } })
          .select(:athlete_id)
      Trophy.where(badge:).where.not(athlete_id: accomplished_athlete_ids).destroy_all
    end
  end

  # rubocop:disable Metrics/MethodLength
  def award_badges(badges, activity_id:, gender:)
    badges.each do |badge|
      time_threshold = badge.info['sec']
      prev_badges = badges.where("(info->>'sec')::integer < ?", time_threshold)
      next_badges = badges.where("(info->>'sec')::integer > ?", time_threshold)
      results_dataset(activity_id:)
        .joins(:athlete)
        .where(total_time: prev_badges.last&.info&.dig('sec').to_i...time_threshold)
        .where(athlete: { gender: })
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
end
