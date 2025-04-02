# frozen_string_literal: true

class Event < ApplicationRecord
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

  after_update_commit :reset_going_athletes, if: -> { !active && saved_change_to_active? }

  validates :name, :code_name, :town, :place, presence: true
  validates :code_name, uniqueness: true, format: { with: /\A[a-z_]+\z/ }

  default_scope { order(:visible_order, :name) }

  scope :in_country, ->(country_code) { joins(:country).where(country: { code: country_code }) }
  scope :without_friends, -> { where.not(id: 4) }

  def self.ransackable_attributes(_auth_object = nil)
    %w[code_name country_id name place town]
  end

  def self.authorized_for(user)
    return all if user.admin?

    where(id: user.permissions.where(subject_class: 'Activity').select(:event_id))
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

  def to_combobox_display = name

  def reset_going_athletes
    ResetGoingAthletesJob.perform_later(id)
  end
end
