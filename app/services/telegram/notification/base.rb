# frozen_string_literal: true

module Telegram
  module Notification
    class Base < ApplicationService
      private

      def notify(telegram_id, **)
        Telegram::Bot.call(
          'sendMessage',
          chat_id: Rails.env.development? ? ENV['DEV_TELEGRAM_ID'] : telegram_id,
          text: text,
          parse_mode: 'Markdown',
          reply_markup: Telegram::Bot::MAIN_KEYBOARD,
          **,
        )
      end

      def routes
        @routes ||= Rails.application.routes.url_helpers
      end

      # Notification message
      def text
        raise NotImplementedError, "Method 'text' must be implemented in the final class"
      end
    end
  end
end
