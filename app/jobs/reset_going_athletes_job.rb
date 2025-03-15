# frozen_string_literal: true

class ResetGoingAthletesJob < ApplicationJob
  queue_as :low

  def perform(event_id)
    # rubocop:disable Rails/SkipsModelValidations
    Athlete.where(going_to_event_id: event_id).update_all(going_to_event_id: nil)
    # rubocop:enable Rails/SkipsModelValidations
  end
end
