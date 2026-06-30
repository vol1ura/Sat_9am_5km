# frozen_string_literal: true

class AthleteStatsUpdateJob < ApplicationJob
  queue_as :low

  def perform(athlete_ids = nil)
    dataset = Athlete.all
    dataset = dataset.where(id: athlete_ids) if athlete_ids

    dataset.find_each do |athlete|
      Athletes::StatsUpdate.call(athlete)
      Wallet::UpdatePassesJob.perform_later(athlete.id) if athlete.wallet_pass_registrations.any?
    end
  end
end
