# frozen_string_literal: true

module Telegram
  module Notification
    module AfterActivity
      class Base < Notification::Base
        def initialize(entity)
          @entity = entity
        end

        def call
          return unless !@entity.informed && (telegram_id = athlete&.user&.telegram_id)

          @entity.update!(informed: true) if notify(telegram_id, disable_web_page_preview: true)
        rescue StandardError => e
          Rollbar.error e, telegram_id: telegram_id, entity_id: @entity.id, entity_class: @entity.class
        end

        private

        def text
          <<~TEXT.squish
            С итоговым протоколом вы можете ознакомиться на [нашем сайте](#{activity_url(activity, host:)}).
            Все ваши результаты и статистика доступны по [ссылке](#{athlete_url(@entity.athlete, host:)}).
          TEXT
        end

        def athlete
          @athlete ||= @entity.athlete
        end

        def activity
          @activity ||= @entity.activity
        end

        def host
          @host ||= activity.event.country.host
        end
      end
    end
  end
end
