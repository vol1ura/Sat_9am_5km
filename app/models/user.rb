# frozen_string_literal: true

class User < ApplicationRecord
  audited max_audits: 20, only: %i[email role first_name last_name telegram_user]
  has_associated_audits

  ROLE = { admin: 0 }.freeze

  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :registerable

  has_one :athlete, dependent: :nullify
  accepts_nested_attributes_for :athlete, reject_if: :all_blank
  has_many :permissions, dependent: :destroy

  validates :first_name, presence: true, format: { with: /\A[a-zа-яё]{2,}\z/i }
  validates :last_name, presence: true, format: { with: /\A[a-zа-яё]{2,}(-[a-zа-яё]{2,})?\z/i }
  validates :telegram_id, uniqueness: true, allow_nil: true

  enum role: ROLE

  def volunteering_position_permission
    permissions.find_by(subject_class: 'VolunteeringPosition', action: %w[manage update])
  end
end
