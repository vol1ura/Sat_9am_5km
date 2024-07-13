# frozen_string_literal: true

module Telegram
  module Notification
    module User
      class NewRunner < Base
        private

        def text
          activity = @user.athlete.results.first.activity
          host = activity.event.country.host

          <<~TEXT
            Привет, #{@user.first_name}.
            В прошлую субботу вы впервые [посетили пробежку S95](#{activity_url(activity, host:)}).
            Надеемся, что вам всё понравилось и вы придёте завтра вновь. \
            Напоминаем, что наши забеги проводятся еженедельно независимо от времени года и погоды. \
            Вы можете пробежать, пройти или помочь с организацией.

            Увидимся в субботу!
          TEXT
        end
      end
    end
  end
end
