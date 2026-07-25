# frozen_string_literal: true

module Wallet
  class UpdatePassesJob < ApplicationJob
    queue_as :default

    def perform(athlete_id)
      athlete = Athlete.find_by(id: athlete_id)
      return unless athlete

      athlete.wallet_pass_registrations.find_each do |registration|
        Wallet::NotificationService.call(registration)
      end
    end
  end
end
