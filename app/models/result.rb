# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :activity, counter_cache: true, touch: true
  belongs_to :athlete, optional: true, touch: true

  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  scope :published, -> { joins(:activity).where(activity: { published: true }) }

  def self.top(male:, limit:)
    results = Arel::Table.new(:results)
    athletes = Arel::Table.new(:athletes)
    activities = Arel::Table.new(:activities)
    composed_table = results.join(activities).on(activities[:id].eq(results[:activity_id]))
                            .join(athletes).on(athletes[:id].eq(results[:athlete_id]))
                            .where(activities[:published].eq(true).and(athletes[:male].eq(male)))
                            .project(results[:total_time].minimum.as('min_tt'), athletes[:id].as('a_id'))
                            .group(athletes[:id]).as('t')
    join_query = "INNER JOIN #{composed_table.to_sql} ON results.athlete_id = t.a_id AND results.total_time = t.min_tt"
    joins(join_query).order(:total_time).first(limit)
  end

  def swap_with_position!(target_position)
    current_athlete = athlete
    target_result = Result.find_by!(position: target_position, activity: activity)
    update!(athlete: target_result.athlete)
    target_result.update!(athlete: current_athlete)
    target_result
  end

  def shift_attributes!(key)
    results = activity.results.includes(:athlete, :activity).where(position: position..).order(:position).to_a
    results.each_cons(2) { |r0, r1| r0.update!(key => r1.public_send(key)) }
    results.last.update!(key => nil)
    results
  end
end
