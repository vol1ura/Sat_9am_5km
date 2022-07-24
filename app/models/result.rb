# frozen_string_literal: true

class Result < ApplicationRecord
  belongs_to :activity, counter_cache: true, touch: true
  belongs_to :athlete, optional: true, touch: true

  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  scope :published, -> { joins(:activity).where(activity: { published: true }) }

  def swap_with_position(target_position)
    current_athlete = athlete
    target_result = Result.find_by!(position: target_position, activity: activity)
    update!(athlete: target_result.athlete)
    target_result.update!(athlete: current_athlete)
    target_result
  end
end
