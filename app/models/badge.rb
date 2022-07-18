# frozen_string_literal: true

class Badge < ApplicationRecord
  has_many :trophies, dependent: :destroy
  has_many :athletes, through: :trophies

  validates :name, presence: true
  validates :picture_link, presence: true, format: { with: /\A[^<>\s]+\z/ }
end
