# frozen_string_literal: true

module Telegram
  module Notification
    module User
      class NewRunner < Base
        def initialize(user)
          @user = user
        end

        def call
          notify(@user.telegram_id)
        rescue StandardError => e
          Rollbar.error e, user_id: @user.id
        end

        private

        def text
          <<~TEXT
            Привет, #{@user.first_name}.
            В прошлую субботу вы впервые [посетили пробежку S95](#{routes.activity_url(@user.athlete.results.first.activity)}).
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
