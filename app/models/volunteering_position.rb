# frozen_string_literal: true

class VolunteeringPosition < ApplicationRecord
  belongs_to :event

  validates :rank, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :number, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :role, presence: true, uniqueness: { scope: :event_id }

  enum role: Volunteer.roles
end
