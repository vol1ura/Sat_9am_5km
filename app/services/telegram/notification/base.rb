# frozen_string_literal: true

module Telegram
  module Notification
    class Base < ApplicationService
      private

      def notify(telegram_id, **)
        Telegram::Bot.call(
          'sendMessage',
          chat_id: Rails.env.development? ? ENV.fetch('DEV_TELEGRAM_ID', telegram_id) : telegram_id,
          text: text,
          parse_mode: 'Markdown',
          reply_markup: Telegram::Bot::MAIN_KEYBOARD,
          **,
        )
      end

      def routes
        @routes ||= Rails.application.routes.url_helpers
      end
    end
  end
end
