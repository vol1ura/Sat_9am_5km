# frozen_string_literal: true

module Telegram
  module Notification
    module User
      class NewRunner < Base
        private

        def text
          activity = @user.athlete.results.first.activity
          country = activity.event.country

          country.localized(
            'notification.user.new_runner',
            first_name: @user.first_name,
            activity_url: activity_url(activity, host: country.host),
          )
        end
      end
    end
  end
end
