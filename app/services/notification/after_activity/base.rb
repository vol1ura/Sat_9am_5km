# frozen_string_literal: true

module Notification
  module AfterActivity
    class Base < Notification::Base
      def initialize(entity)
        @entity = entity
      end

      def call
        user = athlete&.user
        return unless user&.email || user&.telegram_id
        return if user.notification_disabled? :after_activity

        @entity.with_lock do
          next if @entity.informed
          next unless notify user, disable_web_page_preview: true

          @entity.update! informed: true
        end
      end

      private

      def text
        country.localized(
          'notification.after_activity.base',
          activity_url: activity_url(activity, host: country.host),
          athlete_url: athlete_url(@entity.athlete, host: country.host),
        )
      end

      def athlete
        @athlete ||= @entity.athlete
      end

      def activity
        @activity ||= @entity.activity
      end

      def country
        @country ||= activity.country
      end
    end
  end
end
