# frozen_string_literal: true

module Telegram
  module Notification
    module Badge
      class BreakingTimeExpiration < Base
        private

        def text
          <<~TEXT
            #{country.localized(
              'notification.badge.breaking_time_expiration',
              first_name: athlete.user.first_name,
              badge_url: badge_url(@trophy.badge, host: country.host),
            )}
            #{super}
          TEXT
        end
      end
    end
  end
end
