# frozen_string_literal: true

class Activity < ApplicationRecord
  audited
  has_associated_audits

  MAX_SCANNERS = 5

  belongs_to :event

  has_many :results, dependent: :destroy
  has_many :athletes, through: :results
  has_many :volunteers, dependent: :destroy, inverse_of: :activity

  validates :date, presence: true

  after_commit :postprocessing, if: :saved_change_to_published?

  scope :published, -> { where(published: true) }
  scope :in_country, ->(country_code) { joins(event: :country).where(country: { code: country_code }) }

  delegate :name, to: :event, prefix: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[date event_id]
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
    event.activities.published.where(date: ...date).size.next
  end

  def postprocessing
    return unless published

    ResultsProcessingJob.perform_later(id)
    AthletesAwardingJob.perform_later(id) if volunteers.exists?
    BreakingTimeAwardingJob.perform_later if results.exists?
    Telegram::Notification::AfterActivityJob.perform_later(id)
    ClearCache.call
  end
end
