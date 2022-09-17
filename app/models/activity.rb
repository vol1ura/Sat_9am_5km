# frozen_string_literal: true

class Activity < ApplicationRecord
  MAX_SCANNERS = 5

  belongs_to :event

  has_many :results, dependent: :destroy
  has_many :athletes, through: :results
  has_many :volunteers, -> { order :id }, dependent: :destroy, inverse_of: :activity

  before_save :set_date, if: :will_save_change_to_published?

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }

  def leader_result(male: true)
    results.joins(:athlete).where(athlete: { male: male }).order(:position).first
  end

  private

  def set_date
    return unless published

    self.date = Time.zone.today unless date
  end
end
