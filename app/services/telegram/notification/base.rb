# frozen_string_literal: true

module Telegram
  module Notification
    class Base < ApplicationService
      include Rails.application.routes.url_helpers

      private

      def notify(telegram_id, **)
        Telegram::Bot.call(
          'sendMessage',
          chat_id: Rails.env.development? ? ENV['DEV_TELEGRAM_ID'] : telegram_id,
          text: text,
          parse_mode: 'Markdown',
          reply_markup: Telegram::Bot::MAIN_KEYBOARD,
          **,
        ).is_a?(Net::HTTPSuccess)
      end

      # :nocov:
      # Notification message
      def text
        raise NotImplementedError, "Method 'text' must be implemented in the final class"
      end
      # :nocov:
    end
  end
end
