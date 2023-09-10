# frozen_string_literal: true

class Activity < ApplicationRecord
  audited
  has_associated_audits

  MAX_SCANNERS = 5

  belongs_to :event

  has_many :results, dependent: :destroy
  has_many :athletes, through: :results
  has_many :volunteers, dependent: :destroy, inverse_of: :activity

  before_save :set_date, if: %i[will_save_change_to_published? published]
  after_commit :postprocessing, if: %i[saved_change_to_published? published]

  scope :published, -> { where(published: true) }

  delegate :name, to: :event, prefix: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[date event_id published]
  end

  def volunteers_roster
    volunteers
      .joins("LEFT JOIN volunteering_positions vp ON vp.event_id = #{event_id} AND vp.role = volunteers.role")
      .order(:rank)
  end

  def leader_result(male: true)
    results.joins(:athlete).where(athlete: { male: }).order(:position).first
  end

  def number
    event.activities.where(date: ..date).size
  end

  private

  def set_date
    self.date = Date.current unless date
  end

  def postprocessing
    AthleteAwardingJob.perform_later(id) if volunteers.exists?
    BreakingTimeAwardingJob.perform_later if results.exists?
    TelegramNotification::AfterActivityJob.perform_later(id)
    ClearCache.call
  end
end
