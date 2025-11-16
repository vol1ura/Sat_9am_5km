# frozen_string_literal: true

module Telegram
  module Notification
    module Badge
      class RageExpiration < Base
        private

        def text
          <<~TEXT
            #{country.localized(
              'notification.badge.rage_expiration',
              first_name: athlete.user.first_name,
              badge_url: badge_url(@trophy.badge, host: country.host),
              last_total_time: athlete.results.published.order('activity.date').last.total_time.strftime('%M:%S'),
            )}
            #{super}
          TEXT
        end
      end
    end
  end
end
