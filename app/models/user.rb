# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :confirmable, :registerable, :lockable

  has_one :athlete, dependent: :nullify

  # TODO: use bit mask instead of enum for many roles
  enum role: { admin: 0, uploader: 1 }
end
