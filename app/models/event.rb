# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :country
  has_many :activities, dependent: :destroy
  has_many :athletes, dependent: :nullify
  has_many :contacts, dependent: :destroy
  has_many :volunteering_positions, dependent: :destroy

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

  def almost_jubilee_athletes_dataset(type, delta = 1, thresholds = nil)
    thresholds ||= Badge.dataset_of(kind: :participating, type: type.singularize).pluck(:info).pluck('threshold')
    ds =
      athletes
        .where("(stats->?->'count')::integer in (?)", type, thresholds.map { |x| x - delta })
        .order(Arel.sql("stats->?->'count' DESC, updated_at DESC", type))
    return ds if delta > 1 || ds.present?

    almost_jubilee_athletes_dataset(type, delta.next, thresholds)
  end

  def to_combobox_display
    name
  end
end
