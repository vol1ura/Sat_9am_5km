# frozen_string_literal: true

class User < ApplicationRecord
  ROLE = { admin: 0 }.freeze

  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable, :registerable

  has_one :athlete, dependent: :nullify
  accepts_nested_attributes_for :athlete, reject_if: :all_blank
  has_many :permissions, dependent: :destroy

  validates :telegram_id, uniqueness: true, allow_nil: true

  enum role: ROLE
end
