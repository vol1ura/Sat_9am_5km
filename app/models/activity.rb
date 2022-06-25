# frozen_string_literal: true

class Activity < ApplicationRecord
  MAX_SCANNERS = 5

  belongs_to :event

  has_many :results, dependent: :destroy
  has_many :athletes, through: :results

  # validates :date, presence: true

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
end
