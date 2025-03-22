# frozen_string_literal: true

class ResetGoingAthletesJob < ApplicationJob
  queue_as :low

  def perform
    Athlete
      .where.not(going_to_event_id: nil)
      .update_all(going_to_event_id: nil) # rubocop:disable Rails/SkipsModelValidations
  end
end
