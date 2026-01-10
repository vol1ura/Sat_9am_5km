# frozen_string_literal: true

module Telegram
  module Notification
    class RageBadgesExpirationJob < ApplicationJob
      queue_as :low
      discard_on(StandardError) { |_, e| Rollbar.error e }

      def perform
        Trophy.where(badge: ::Badge.rage_kind, date: Date.current.prev_week(:saturday)).find_each do |trophy|
          Badge::RageExpiration.call(trophy)
        end
      end
    end
  end
end
