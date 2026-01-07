# frozen_string_literal: true

class Event < ApplicationRecord
  AVAILABLE_TIMEZONES = ActiveSupport::TimeZone.all.map { |tz| tz.tzinfo.name }.uniq.freeze
  SUMMER_MONTHS = 4..10

  belongs_to :country
  has_many :activities, dependent: :destroy
  has_many :athletes, dependent: :nullify
  has_many :contacts, dependent: :destroy
  has_many :volunteering_positions, dependent: :destroy
  has_many(
    :going_athletes,
    class_name: 'Athlete',
    foreign_key: :going_to_event_id,
    dependent: :nullify,
    inverse_of: false,
  )

  has_one_attached :summer_image do |attachable|
    attachable.variant :full, resize_to_fill: [2800, 1060]
    attachable.variant :thumb, resize_to_fill: [1400, 530]
  end

  has_one_attached :winter_image do |attachable|
    attachable.variant :full, resize_to_fill: [2800, 1060]
    attachable.variant :thumb, resize_to_fill: [1400, 530]
  end

  validates :summer_image,
            content_type: %i[png jpeg webp],
            dimension: { width: { min: 2800 }, height: { min: 1060 } },
            size: { between: (150.kilobytes)..(5.megabytes) }
  validates :winter_image,
            content_type: %i[png jpeg webp],
            dimension: { width: { min: 2800 }, height: { min: 1060 } },
            size: { between: (150.kilobytes)..(5.megabytes) }

  after_update_commit :reset_going_athletes, if: -> { !active && saved_change_to_active? }

  validates :name, :code_name, :town, :place, presence: true
  validates :code_name, uniqueness: true, format: { with: /\A[a-z_]+\z/ }
  validates :timezone, presence: true, inclusion: { in: AVAILABLE_TIMEZONES }

  default_scope { order(:visible_order, :name) }

  scope :active, -> { where(active: true) }
  scope :in_country, ->(country_code) { joins(:country).where(country: { code: country_code }) }
  scope :without_friends, -> { where.not(id: [4, 31]) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[code_name country_id name town]
  end

  def self.authorized_for(user)
    return all if user.admin?

    where(id: user.permissions.where(subject_class: 'Activity').select(:event_id))
  end

  def timezone_object
    ActiveSupport::TimeZone[timezone]
  end

  def almost_jubilee_athletes_dataset(type, delta = 1)
    thresholds = Badge.participating_thresholds[type.singularize.to_sym].map { |x| x - delta }
    ds =
      athletes
        .where("(stats->?->'count')::integer in (?)", type, thresholds)
        .order(Arel.sql("stats->?->'count' DESC, updated_at DESC", type))
    return ds if delta > 1 || ds.present?

    almost_jubilee_athletes_dataset(type, delta.next)
  end

  def leader_results_dataset(gender:)
    Result
      .published
      .joins(:athlete)
      .where(activity: { event_id: id }, athlete: { gender: })
      .select('DISTINCT ON (results.activity_id) results.*')
      .order('results.activity_id, results.position')
  end

  def to_combobox_display = name

  def current_image
    return summer_image if SUMMER_MONTHS.cover?(Time.current.month) || !winter_image.attached?

    winter_image
  end

  private

  def reset_going_athletes
    RenewGoingToEventJob.perform_later(id)
  end
end
