# frozen_string_literal: true

module Telegram
  module Notification
    module AfterActivity
      class Result < Base
        private

        def text
          <<~TEXT
            #{country.localized(
              'notification.after_activity.result',
              first_name: athlete.user.first_name,
              number: activity.number,
              event_name: activity.event_name,
              position: @entity.position,
              total_time: @entity.time_string,
              count: activity.results.count,
            )}
            #{super}
          TEXT
        end
      end
    end
  end
end
