# frozen_string_literal: true

module Telegram
  module Notification
    module User
      class NewRunner < Base
        def initialize(user)
          @user = user
        end

        def call
          return unless @user.telegram_id

          notify(@user.telegram_id)
        rescue StandardError => e
          Rollbar.error e, user_id: @user.id
        end

        private

        def text
          activity = @user.athlete.results.first.activity
          host = "s95.#{activity.event.country.code}"

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
