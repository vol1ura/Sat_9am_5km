# frozen_string_literal: true

class User < ApplicationRecord
  audited max_audits: 20, only: %i[email role first_name last_name telegram_user]
  has_associated_audits

  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :registerable

  has_one :athlete, dependent: :nullify
  accepts_nested_attributes_for :athlete, reject_if: :all_blank
  has_many :permissions, dependent: :destroy

  has_one_attached :image do |attachable|
    attachable.variant :web, resize_to_fill: [200, 200]
  end

  validates :first_name, presence: true, format: { with: /\A[a-zа-яё]{2,}\z/i }
  validates :last_name, presence: true, format: { with: /\A[a-zа-яё]{2,}(-[a-zа-яё]{2,})?\z/i }
  validates :telegram_id, uniqueness: true, allow_nil: true
  validates :image,
            content_type: %i[png jpg jpeg],
            dimension: { min: 200..200 },
            size: { less_than: 10.megabytes }

  enum role: { admin: 0 }

  before_save :update_athlete_name, if: proc { will_save_change_to_first_name? || will_save_change_to_last_name? }

  def self.ransackable_attributes(_auth_object = nil)
    %w[email first_name last_name telegram_user]
  end

  def volunteering_position_permission
    permissions.find_by(subject_class: 'VolunteeringPosition', action: %w[manage update])
  end

  def full_name
    "#{first_name} #{last_name.upcase}"
  end

  private

  def update_athlete_name
    athlete.name = full_name if athlete
  end
end
