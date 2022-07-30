# frozen_string_literal: true

class User < ApplicationRecord
  ROLE = { admin: 0, uploader: 1 }.freeze
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable, :registerable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :lockable

  has_one :athlete, dependent: :nullify

  # TODO: use bit mask instead of enum for many roles
  enum role: ROLE
end
