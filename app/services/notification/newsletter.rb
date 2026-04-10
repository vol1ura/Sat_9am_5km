# frozen_string_literal: true

module Notification
  class Newsletter < ApplicationService
    def initialize(newsletter, user, increment: true)
      @newsletter = newsletter
      @user = user
      @increment = increment
    end

    def call
      if @user.email
        deliver_by_email
      elsif @user.telegram_id
        deliver_by_telegram
      else
        return
      end

      @newsletter.with_lock { @newsletter.update!(sent_count: @newsletter.sent_count.next) } if @increment
    rescue StandardError => e
      Rollbar.error e, user_id: @user.id, newsletter_id: @newsletter.id
    end

    private

    def deliver_by_email
      html = build_email_html
      UserNotificationMailer.notify(@user, html).deliver_later
    end

    def deliver_by_telegram
      Telegram::Bot.call(
        @newsletter.picture_link.present? ? 'sendPhoto' : 'sendMessage',
        **api_method_params,
        chat_id: Rails.env.local? ? ENV['DEV_TELEGRAM_ID'] : @user.telegram_id,
        parse_mode: 'Markdown',
        disable_web_page_preview: true,
        reply_markup: Telegram::Bot::MAIN_KEYBOARD,
      )
    end

    def build_email_html
      html = MarkdownConverter.to_html(@newsletter.body)
      return html if @newsletter.picture_link.blank?

      "<img src=\"#{@newsletter.picture_link}\" style=\"max-width:400px;width:100%\"><br>#{html}"
    end

    def api_method_params
      return { text: @newsletter.body } if @newsletter.picture_link.blank?

      {
        photo: @newsletter.picture_link,
        caption: @newsletter.body,
      }
    end
  end
end
