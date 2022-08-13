# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :activity, counter_cache: true, touch: true
  belongs_to :athlete, optional: true, touch: true

  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  scope :published, -> { joins(:activity).where(activity: { published: true }) }

  def self.top(male:, limit:)
    sql = <<-SQL.squish
      SELECT res.* FROM results res INNER JOIN (
        SELECT MIN(total_time) as min_tt, athlete.id as a_id FROM "results"
        INNER JOIN "activities" "activity" ON "activity"."id" = "results"."activity_id"
        INNER JOIN "athletes" "athlete" ON "athlete"."id" = "results"."athlete_id"
        WHERE "activity"."published" = true AND "athlete"."male" = ?
        GROUP BY a_id
      ) t ON res.athlete_id = t.a_id AND res.total_time = t.min_tt
      ORDER BY res.total_time
    SQL
    find_by_sql([sql, male]).first(limit)
  end

  def swap_with_position(target_position)
    current_athlete = athlete
    target_result = Result.find_by!(position: target_position, activity: activity)
    update!(athlete: target_result.athlete)
    target_result.update!(athlete: current_athlete)
    target_result
  end

  def shift_attributes(key)
    results = activity.results.includes(:athlete, :activity).where(position: position..).order(:position).to_a
    results.each_cons(2) { |r0, r1| r0.update!(key => r1.public_send(key)) }
    results.last.update!(key => nil)
    results
  end
end
