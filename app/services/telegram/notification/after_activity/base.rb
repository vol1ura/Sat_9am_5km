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
          Rollbar.error e
        end

        private

        def text
          <<~TEXT.squish
            С итоговым протоколом вы можете ознакомиться на [нашем сайте](#{routes.activity_url(activity)}).
            Все ваши результаты и статистика доступны по [ссылке](#{routes.athlete_url(@entity.athlete)}).
          TEXT
        end

        def athlete
          @athlete ||= @entity.athlete
        end

        def activity
          @activity ||= @entity.activity
        end
      end
    end
  end
end