# frozen_string_literal: true

class EmptyAthletesCleanupJob < ApplicationJob
  queue_as :low

  def perform
    Athlete
      .where(user_id: nil)
      .where.missing(:results)
      .where.not(id: Volunteer.select(:athlete_id))
      .where(name: [nil, ''])
      .destroy_all
  end
end
