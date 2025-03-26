# frozen_string_literal: true

class ResetGoingAthletesJob < ApplicationJob
  queue_as :low

  def perform
    Athlete
      .where.not(going_to_event_id: nil)
      .update_all(going_to_event_id: nil) # rubocop:disable Rails/SkipsModelValidations

    Volunteer
      .eager_load(:activity)
      .includes(:athlete)
      .where(activities: { date: Date.current.next_occurring(:saturday) })
      .find_each do |volunteer|
        volunteer.athlete.update(going_to_event_id: volunteer.activity.event_id)
      end
  end
end
