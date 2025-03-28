# frozen_string_literal: true

class ResetGoingAthletesJob < ApplicationJob
  queue_as :low

  def perform(event_id = nil)
    dataset = Athlete.where.not(going_to_event_id: nil)
    dataset = dataset.rewhere(going_to_event_id: event_id) if event_id
    dataset.update_all(going_to_event_id: nil) # rubocop:disable Rails/SkipsModelValidations

    return if event_id

    Volunteer
      .eager_load(:activity)
      .includes(:athlete)
      .where(activities: { date: Date.current.next_occurring(:saturday) })
      .find_each do |volunteer|
        volunteer.athlete.update(going_to_event_id: volunteer.activity.event_id)
      end
  end
end
