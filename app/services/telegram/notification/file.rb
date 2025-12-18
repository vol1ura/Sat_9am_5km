# frozen_string_literal: true

module Telegram
  module Notification
    class File < ApplicationService
      def initialize(user, file:, filename:, caption:)
        @user = user
        @file = file
        @filename = filename
        @caption = caption
      end

      def call
        return unless @user.telegram_id

        Bot.call(
          'sendDocument',
          form_data: [
            ['document', @file, { filename: @filename, content_type: 'text/csv' }],
            ['caption', @caption],
            ['chat_id', @user.telegram_id.to_s],
          ],
        )
      end
    end
  end
end
