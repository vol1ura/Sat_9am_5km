# frozen_string_literal: true

class AthleteStatsUpdateJob < ApplicationJob
  queue_as :low

  def perform(athlete_ids = nil)
    dataset = Athlete.all
    dataset = dataset.where(id: athlete_ids) if athlete_ids

    dataset.find_each do |athlete|
      Athletes::StatsUpdate.call(athlete)
    end
  end
end
