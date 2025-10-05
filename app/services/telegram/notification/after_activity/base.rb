# frozen_string_literal: true

module Telegram
  module Notification
    module AfterActivity
      class Base < Notification::Base
        def initialize(entity)
          @entity = entity
        end

        def call
          return unless (telegram_id = athlete&.user&.telegram_id)

          @entity.with_lock do
            return if @entity.informed

            notify!(telegram_id, disable_web_page_preview: true)
            @entity.update!(informed: true)
          end
        rescue StandardError => e
          Rollbar.error e, telegram_id: telegram_id, entity_id: @entity.id, entity_class: @entity.class
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
          @country ||= activity.event.country
        end
      end
    end
  end
end
