# frozen_string_literal: true

module Telegram
  module Notification
    class BreakingTimeBadgesExpirationJob < ApplicationJob
      queue_as :low
      discard_on(StandardError) { |_, e| Rollbar.error e }

      def perform
        threshold_date = BreakingTimeAwardingJob::EXPIRATION_PERIOD.ago.to_date + 1.week
        Trophy.where(badge: ::Badge.breaking_kind, date: ..threshold_date).find_each do |trophy|
          Badge::BreakingTimeExpiration.call(trophy)
        end
      end
    end
  end
end
