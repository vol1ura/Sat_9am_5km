# frozen_string_literal: true

class AthletePersonalBestsUpdateJob < ApplicationJob
  queue_as :low

  def perform(athlete_id)
    athlete = Athlete.find athlete_id

    athlete.results.published.order(:date).select(:activity_id).each do |result|
      ResultsProcessingJob.perform_now result.activity_id
    end
  end
end
