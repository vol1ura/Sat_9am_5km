# frozen_string_literal: true

class Activity < ApplicationRecord
  audited except: [:token]
  has_associated_audits

  belongs_to :event

  has_many :results, dependent: :destroy
  has_many :athletes, through: :results
  has_many :volunteers, dependent: :destroy, inverse_of: :activity

  validates :date, presence: true
  validates_associated :volunteers, if: :will_save_change_to_date?

  after_commit :postprocessing, if: :saved_change_to_published?

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :in_country, ->(country_code) { joins(event: :country).where(country: { code: country_code }) }

  delegate :name, to: :event, prefix: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[date event_id]
  end

  def volunteers_roster
    volunteers
      .joins("LEFT JOIN volunteering_positions vp ON vp.event_id = #{event_id} AND vp.role = volunteers.role")
      .order(:rank, :role, :comment)
  end

  def participants
    Athlete.where(id: results.select(:athlete_id)).or(Athlete.where(id: volunteers.select(:athlete_id))).distinct
  end

  def leader_result(male: true)
    results.joins(:athlete).where(athlete: { male: }).order(:position).first
  end

  def number
    event.activities.published.where(date: ...date).size.next
  end

  def correct?
    subquery = results.left_joins(:athlete).select(
      'position, LEAD(position, 1) OVER (ORDER BY position) AS next_position, ' \
      'total_time, LEAD(total_time, 1) OVER (ORDER BY position) AS next_total_time, ' \
      'athlete_id, name, male',
    ).to_sql
    Result
      .from("(#{subquery}) AS ext_results")
      .where(
        'total_time IS NULL OR next_position != position + 1 OR total_time > next_total_time OR ' \
        '(athlete_id IS NOT NULL AND (name IS NULL OR male IS NULL))',
      )
      .empty?
  end

  def doubled_results
    return Result.none if date.strftime('%-d.%-m') == '1.1'

    Result
      .where(athlete_id: results.select(:athlete_id))
      .where(activity_id: Activity.published.where(date:).where.not(id:).select(:id))
  end

  def incorrect_running_volunteers
    return Volunteer.none if results.empty?

    volunteers
      .where(role: %w[event_closer pacemaker attendant])
      .where.not(athlete_id: results.where.not(athlete_id: nil).select(:athlete_id))
  end

  def clear_live_results!
    event.update!(live_results: nil) if date.today?
  end

  def postprocessing
    return unless published

    ResultsProcessingJob.perform_later(id)
    AthletesAwardingJob.perform_later(id)
    MinuteBingoAwardingJob.perform_later(id)
    BreakingTimeAwardingJob.perform_later(id)
    FivePlusAwardingJob.perform_later(id)
    AthleteStatsUpdateJob.set(wait: 10.minutes).perform_later(participants.ids)
    Telegram::Notification::AfterActivityJob.perform_later(id)
    ClearCache.call
  end
end
