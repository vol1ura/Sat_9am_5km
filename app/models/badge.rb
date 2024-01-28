# frozen_string_literal: true

class Badge < ApplicationRecord
  BADGE_TYPES = %w[result volunteer].freeze
  ASSOCIATION_TYPE_MAPPING = {
    'result' => :results,
    'volunteer' => :volunteering,
  }.freeze

  has_many :trophies, dependent: :destroy
  has_many :athletes, through: :trophies

  validates :kind, :name, presence: true
  validates :picture_link, presence: true, format: { with: /\A[^<>\s]+\z/ }

  enum kind: {
    funrun: 0, participating: 10, home_participating: 11, jubilee_participating: 12,
    tourist: 20, breaking: 30, rage: 40, record: 100
  }, _suffix: true

  def self.dataset_of(kind:, type:)
    public_send("#{kind}_kind").where("info->>'type' = ?", type).order(Arel.sql("info->'threshold'"))
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[conditions kind name received_date]
  end
end
