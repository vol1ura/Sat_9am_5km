# frozen_string_literal: true

class User < ApplicationRecord
  ROLE = { admin: 0 }.freeze

  # Include default devise modules. Others available are:
  # :timeoutable, :trackable, :registerable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable

  has_one :athlete, dependent: :nullify
  has_many :permissions, dependent: :destroy

  validates :telegram_id, uniqueness: true, allow_nil: true

  enum role: ROLE
end
