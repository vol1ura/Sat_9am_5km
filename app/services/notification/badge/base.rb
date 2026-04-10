# frozen_string_literal: true

module Notification
  module Badge
    class Base < Notification::Base
      def initialize(trophy)
        @trophy = trophy
      end

      def call
        user = athlete&.user
        return unless user&.email || user&.telegram_id
        return if user.notification_disabled? :badge

        notify! user, disable_web_page_preview: true
      rescue StandardError => e
        Rollbar.error e, user_id: user&.id, trophy_id: @trophy.id
      end

      private

      def athlete
        @athlete ||= @trophy.athlete
      end

      def text
        country.localized 'notification.badge.base', athlete_url: athlete_url(athlete, host: country.host)
      end

      def country
        @country ||= athlete.results.published.last.activity&.event&.country || Country.default
      end
    end
  end
end
