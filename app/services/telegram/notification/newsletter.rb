# frozen_string_literal: true

module Telegram
  module Notification
    class Newsletter < ApplicationService
      def initialize(newsletter, user)
        @newsletter = newsletter
        @user = user
      end

      def call
        return unless @user&.telegram_id

        notify(Rails.env.local? ? ENV['DEV_TELEGRAM_ID'] : @user.telegram_id)
      rescue StandardError => e
        Rollbar.error e, user_id: @user.id, newsletter_id: @newsletter.id
      end

      private

      def api_method_params
        return { text: @newsletter.body } if @newsletter.picture_link.blank?

        {
          photo: @newsletter.picture_link,
          caption: @newsletter.body,
        }
      end

      def notify(telegram_id)
        response = Telegram::Bot.call(
          @newsletter.picture_link.present? ? 'sendPhoto' : 'sendMessage',
          **api_method_params,
          chat_id: telegram_id,
          parse_mode: 'Markdown',
          disable_web_page_preview: true,
          reply_markup: Bot::MAIN_KEYBOARD,
        )
        raise "Notification failed. Response: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
      end
    end
  end
end
