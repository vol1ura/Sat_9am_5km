# frozen_string_literal: true

module Telegram
  module Notification
    module Badge
      class Base < Notification::Base
        def initialize(trophy)
          @trophy = trophy
        end

        def call
          return unless (telegram_id = athlete&.user&.telegram_id)

          notify(telegram_id, disable_web_page_preview: true)
        rescue StandardError => e
          Rollbar.error e
        end

        private

        def athlete
          @athlete ||= @trophy.athlete
        end

        def text
          "Все ваши награды и результаты можно посмотреть [тут](#{routes.athlete_url(athlete)})."
        end
      end
    end
  end
end
