# frozen_string_literal: true

class Activity < ApplicationRecord
  MAX_SCANNERS = 5

  belongs_to :event

  has_many :results, dependent: :destroy
  has_many :athletes, through: :results
  has_many :volunteers, dependent: :destroy, inverse_of: :activity

  before_save :postprocessing, if: %i[will_save_change_to_published? published]
  after_save :enqueue_awardings, if: %i[saved_change_to_published? published]

  scope :published, -> { where(published: true) }

  def volunteers_roster
    volunteers
      .joins("LEFT JOIN volunteering_positions vp on vp.event_id = #{event_id} AND vp.role = volunteers.role")
      .order(:rank)
  end

  def leader_result(male: true)
    results.joins(:athlete).where(athlete: { male: male }).order(:position).first
  end

  def number
    event.activities.where(date: ..date).size
  end

  private

  def postprocessing
    self.date = Time.zone.today unless date
  end

  def enqueue_awardings
    AthleteAwardingJob.perform_later(id) if volunteers.exists?
    BreakingTimeAwardingJob.perform_later if results.exists?
  end
end
