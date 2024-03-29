# frozen_string_literal: true

module Telegram
  module Notification
    module Badge
      class BreakingTimeExpiration < Base
        private

        def text
          <<~TEXT
            Привет, #{athlete.user.first_name}.
            Через неделю истекает срок действия вашей [награды](#{badge_url(@trophy.badge, host:)}) за скорость.
            Попробуйте удержать её!

            #{super}
          TEXT
        end
      end
    end
  end
end
