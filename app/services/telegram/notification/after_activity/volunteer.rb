# frozen_string_literal: true

module Telegram
  module Notification
    module AfterActivity
      class Volunteer < Base
        private

        def text
          <<~TEXT
            #{country.localized(
              'notification.after_activity.volunteer',
              first_name: athlete.user.first_name,
              number: activity.number,
              event_name: activity.event_name,
            )}
            #{super}
            #{country.localized 'notification.common.signature'}
          TEXT
        end
      end
    end
  end
end
