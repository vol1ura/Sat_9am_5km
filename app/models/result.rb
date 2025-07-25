# frozen_string_literal: true

class Result < ApplicationRecord
  audited associated_with: :activity, except: %i[informed personal_best first_run]

  belongs_to :activity, touch: true
  belongs_to :athlete, optional: true, touch: true

  validates :position, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :athlete_id, uniqueness: { scope: :activity_id }, allow_nil: true

  scope :published, -> { joins(:activity).where(activity: { published: true }) }

  delegate :date, to: :activity

  def self.total_time(hour = 0, min, sec)
    Time.zone.local(2000, 1, 1, hour, min, sec)
  end

  def correct?
    return false unless total_time

    !athlete_id || (athlete.name.present? && !athlete.male.nil?)
  end

  def swap_with_position!(target_position)
    current_athlete = athlete
    target_result = Result.find_by!(position: target_position, activity: activity)
    target_athlete = target_result.athlete
    transaction do
      target_result.update!(athlete: nil)
      update!(athlete: target_athlete)
      target_result.update!(athlete: current_athlete)
    end
    target_result
  end

  def shift_attributes!(key)
    results = activity.results.includes(:athlete).where(position: position..).order(:position).to_a
    transaction do
      without_auditing do
        results.each_cons(2) do |res0, res1|
          value = res1.public_send(key)
          res1.update!(key => nil)
          res0.update!(key => value)
        end
      end
    end
    results
  end

  def insert_new_result_above!
    transaction do
      activity.results.where(position: position..).update_all 'position = position + 1'
      activity.results.create! position:
    end
  end
end
