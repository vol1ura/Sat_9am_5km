# frozen_string_literal: true

class VolunteeringPosition < ApplicationRecord
  belongs_to :event
  belongs_to :activity, optional: true

  validates :rank, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :number, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :role, uniqueness: { scope: %i[event_id activity_id] }
  validate :activity_belongs_to_event

  enum :role, Volunteer.roles, instance_methods: false, validate: true

  private

  def activity_belongs_to_event
    errors.add(:activity, :invalid_event) if activity && activity.event_id != event_id
  end
end
