# frozen_string_literal: true

module TelegramNotification
  module Badge
    class BreakingTimeExpiration < ApplicationService
      def initialize(trophy)
        @trophy = trophy
      end

      def call
        return unless (telegram_id = @trophy.athlete&.user&.telegram_id)

        Bot.call('sendMessage', chat_id: telegram_id, text: text, disable_web_page_preview: true, parse_mode: 'Markdown')
      rescue StandardError => e
        Rollbar.error e
      end

      private

      def text
        <<~TEXT
          Через неделю истекает срок действия вашей [награды](#{routes.badge_url(@trophy.badge)}) за скорость.
          Попробуйте удержать её!

          Все ваши награды и результаты можно посмотреть [тут](#{routes.athlete_url(@trophy.athlete)}).
        TEXT
      end

      def routes
        @routes ||= Rails.application.routes.url_helpers
      end
    end
  end
end
