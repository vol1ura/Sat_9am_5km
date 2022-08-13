# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :activity, counter_cache: true, touch: true
  belongs_to :athlete, optional: true, touch: true

  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  scope :published, -> { joins(:activity).where(activity: { published: true }) }
  scope :top, ->(male, limit) { joins(:athlete).where(athlete: { male: male }).order(:total_time, :position).limit(limit) }

  # before_save :change_positions, if: :will_save_change_to_position?

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
