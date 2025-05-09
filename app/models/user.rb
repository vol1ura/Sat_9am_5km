# frozen_string_literal: true

class User < ApplicationRecord
  AVAILABLE_PROMOTIONS = %w[spartacus].freeze

  audited only: %i[email role first_name last_name telegram_user promotions]
  has_associated_audits

  # Include default devise modules. Others available are:
  # :timeoutable, :trackable, :validatable
  devise(
    :database_authenticatable, :recoverable, :rememberable, :confirmable, :lockable, :registerable,
    :omniauthable, omniauth_providers: %i[telegram],
  )

  has_one :athlete, dependent: :nullify
  accepts_nested_attributes_for :athlete, reject_if: :all_blank
  has_many :permissions, dependent: :destroy

  has_one_attached :image do |attachable|
    attachable.variant :web, resize_to_fill: [200, 200]
  end

  validates :first_name, presence: true, format: { with: /\A[[:alpha:]]+(-[[:alpha:]]{2,})?\z/ }
  validates :last_name, presence: true, format: { with: /\A[[:alpha:]]+([-' ][[:alpha:]]{2,})?\z/ }
  validates :email, :password, presence: true, if: -> { telegram_id.nil? }
  validates :telegram_id, :email, :auth_token, uniqueness: true, allow_nil: true
  validates :emergency_contact_phone, phone: true, allow_nil: true
  validates :emergency_contact_name, presence: true, if: -> { emergency_contact_phone }
  validates :image,
            content_type: %i[png jpeg],
            dimension: { min: 200..200 },
            size: { less_than: 10.megabytes }
  validate :promotions_must_be_available, if: :will_save_change_to_promotions?

  enum :role, { admin: 0 }, validate: { allow_nil: true }

  before_validation :format_emergency_contact, if: :will_save_change_to_emergency_contact_phone?
  before_save :update_athlete_name, if: proc { will_save_change_to_first_name? || will_save_change_to_last_name? }

  def self.ransackable_attributes(_auth_object = nil)
    %w[email first_name last_name telegram_user]
  end

  def volunteering_position_permission
    permissions.find_by(subject_class: 'VolunteeringPosition', action: %w[manage update])
  end

  def full_name = "#{first_name} #{last_name.upcase}"

  private

  def update_athlete_name
    athlete.name = full_name if athlete
  end

  def format_emergency_contact
    self.emergency_contact_phone = Phonelib.parse(emergency_contact_phone).e164
    self.emergency_contact_name = nil unless emergency_contact_phone
  end

  def promotions_must_be_available
    errors.add(:promotions, :inclusion) unless (promotions - promotions_was).all? { |p| AVAILABLE_PROMOTIONS.include? p }
  end
end
