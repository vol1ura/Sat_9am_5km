# frozen_string_literal: true

class Badge < ApplicationRecord
  BADGE_TYPES = %w[result volunteer].freeze
  ASSOCIATION_TYPE_MAPPING = {
    'result' => :results,
    'volunteer' => :volunteering,
  }.freeze

  has_many :trophies, dependent: :destroy
  has_many :athletes, through: :trophies

  has_one_attached :image do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100], preprocessed: true
    attachable.variant :web, resize_to_limit: [200, 200], preprocessed: true
  end

  validates :kind, :name, :conditions, presence: true

  validates :image, attached: true,
                    content_type: :png,
                    aspect_ratio: :square,
                    dimension: { width: { in: 200..400 } },
                    size: { less_than: 300.kilobytes }

  enum :kind, {
    funrun: 0, full_profile: 1, participating: 10, home_participating: 11, jubilee_participating: 12,
    tourist: 20, breaking: 30, rage: 40, five_plus: 41, minute_bingo: 50, record: 100
  }, suffix: true

  store_accessor :info, :country_code

  translates :name, :conditions

  def self.dataset_of(kind:, type:)
    public_send(:"#{kind}_kind").where("info->>'type' = ?", type).order(Arel.sql("info->'threshold'"))
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[kind name received_date]
  end
end
