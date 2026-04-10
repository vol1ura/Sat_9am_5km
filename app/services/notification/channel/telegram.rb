# frozen_string_literal: true

module Notification
  module Channel
    class Telegram
      def self.deliver(user, text:, **)
        telegram_id = Rails.env.local? ? ENV['DEV_TELEGRAM_ID'] : user.telegram_id
        ::Telegram::Bot.call(
          'sendMessage',
          chat_id: telegram_id,
          text: text,
          parse_mode: 'Markdown',
          reply_markup: ::Telegram::Bot::MAIN_KEYBOARD,
          **,
        )
      end
    end
  end
end
