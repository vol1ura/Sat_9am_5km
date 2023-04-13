# frozen_string_literal: true

module TelegramNotification
  module Badge
    class Base < ApplicationService
      def initialize(trophy)
        @trophy = trophy
      end

      def call
        return unless (telegram_id = athlete&.user&.telegram_id)

        Bot.call('sendMessage', chat_id: telegram_id, text: text, disable_web_page_preview: true, parse_mode: 'Markdown')
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

      def routes
        @routes ||= Rails.application.routes.url_helpers
      end
    end
  end
end
