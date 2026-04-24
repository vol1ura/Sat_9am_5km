# frozen_string_literal: true

class User < ApplicationRecord
  AVAILABLE_PROMOTIONS = %w[spartacus].freeze
  NOTIFICATION_TYPES = %w[newsletter badge after_activity volunteer_reminder other].freeze

  audited only: %i[email role first_name last_name telegram_user promotions policy_accepted]
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

  normalizes :email, with: ->(value) { value.presence }

  validates :first_name, presence: true, format: { with: /\A[[:alpha:]]+(-[[:alpha:]]{2,})?\z/ }
  validates :last_name, presence: true, format: { with: /\A[[:alpha:]]+([-' ][[:alpha:]]{2,})?\z/ }
  validates :email, presence: true, if: -> { telegram_id.nil? }
  validates :telegram_id, :email, :auth_token, uniqueness: true, allow_nil: true
  validates :emergency_contact_phone, phone: true, allow_nil: true
  validates :emergency_contact_name, presence: true, if: -> { emergency_contact_phone }
  validates :image,
            content_type: %i[png jpeg webp],
            dimension: { min: 200..200 },
            size: { less_than: 10.megabytes }
  validate :promotions_must_be_available, if: :will_save_change_to_promotions?

  enum :role, { super_admin: 0, admin: 1 }, validate: { allow_nil: true }

  before_validation :format_emergency_contact, if: :will_save_change_to_emergency_contact_phone?
  before_save :update_athlete_name, if: proc { will_save_change_to_first_name? || will_save_change_to_last_name? }

  scope :protocol_responsible, lambda { |activity|
    joins(:athlete).where(athlete: { id: activity.volunteers.where(role: %i[director result_handler]).select(:athlete_id) })
  }

  def self.ransackable_attributes(_auth_object = nil)
    %w[email first_name last_name telegram_user]
  end

  def full_name = "#{first_name} #{last_name.upcase}"

  def admin? = super || super_admin?

  def favorite_event?(event)
    favorite_event_ids.include?(event.id)
  end

  def toggle_favorite_event(event)
    if favorite_event?(event)
      update!(favorite_event_ids: favorite_event_ids - [event.id])
    else
      update!(favorite_event_ids: favorite_event_ids + [event.id])
    end
  end

  def favorite_events = Event.where(id: favorite_event_ids)

  def notification_disabled?(type)
    disabled_notifications.include?(type.to_s)
  end

  private

  def send_devise_notification(notification, *)
    devise_mailer.send(notification, self, *).deliver_later
  end

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
