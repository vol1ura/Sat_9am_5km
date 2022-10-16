# frozen_string_literal: true

class BreakingTimeAwardingJob < ApplicationJob
  queue_as :default

  EXPIRATION_PERIOD = 3 # In months
  BREAKING_TIME_BADGES = {
    male: [
      { id: 13, min: 16, male: true, next_ids: [14, 15] },
      { id: 14, min: 18, male: true, prev_ids: [13], next_ids: [15] },
      { id: 15, min: 20, male: true, prev_ids: [13, 14] }
    ],
    female: [
      { id: 16, min: 19, male: false, next_ids: [17, 18] },
      { id: 17, min: 21, male: false, prev_ids: [16], next_ids: [18] },
      { id: 18, min: 23, male: false, prev_ids: [16, 17] }
    ]
  }.freeze

  def perform
    expire_badges
    award_badges
  end

  private

  def expire_badges
    BREAKING_TIME_BADGES.values.flatten.each do |badge|
      accomplished_athlete_ids =
        Result.joins(:activity, athlete: :trophies)
              .where(activity: { date: EXPIRATION_PERIOD.months.ago.. })
              .where(total_time: ...minutes_threshold(badge[:min]))
              .where(athlete: { trophies: { badge: badge[:id] } }).select(:athlete_id)
      Trophy.where(badge_id: badge[:id]).where.not(athlete_id: accomplished_athlete_ids).delete_all
    end
  end

  def award_badges
    BREAKING_TIME_BADGES.each do |gender, badges|
      badges.unshift(min: 0).each_cons(2) { |prev_badge, badge| process_badge(prev_badge, badge, gender == :male) }
    end
  end

  def process_badge(prev_badge, badge, male)
    Result
      .joins(:activity, :athlete)
      .where(activity: { date: EXPIRATION_PERIOD.months.ago.. })
      .where(total_time: minutes_threshold(prev_badge[:min])..)
      .where(total_time: ...minutes_threshold(badge[:min]))
      .where(athlete: { male: male })
      .order(:date)
      .select(:athlete_id, :date).each do |res|
        next if badge.key?(:prev_ids) && Trophy.exists?(athlete_id: res.athlete_id, badge_id: badge[:prev_ids])

        trophy = Trophy.find_or_initialize_by(badge_id: badge[:id], athlete_id: res.athlete_id)
        trophy.date = res.date
        trophy.transaction do
          Trophy.where(athlete_id: res.athlete_id, badge_id: badge[:next_ids]).delete_all if badge.key?(:next_ids)
          trophy.save!
        end
      end
  end

  def minutes_threshold(minutes)
    Time.zone.local(2000, 1, 1, 0, minutes, 0)
  end
end
