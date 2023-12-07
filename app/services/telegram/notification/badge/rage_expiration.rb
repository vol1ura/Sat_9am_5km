# frozen_string_literal: true

module Telegram
  module Notification
    module Badge
      class RageExpiration < Base
        private

        def text
          <<~TEXT
            Привет, #{athlete.user.first_name}!
            В прошлую субботу вы получили [Раж значок](#{routes.badge_url(@trophy.badge)}) за непрерывное улучшение результатов.
            Попробуйте удержать его! Для этого на любом следующем забеге вам надо показать результат быстрее #{last_total_time}.

            #{super}
          TEXT
        end

        def last_total_time
          athlete.results.published.order('activity.date').last.total_time.strftime('%M:%S')
        end
      end
    end
  end
end
