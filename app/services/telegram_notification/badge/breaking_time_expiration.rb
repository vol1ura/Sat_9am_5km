# frozen_string_literal: true

module TelegramNotification
  module Badge
    class BreakingTimeExpiration < Base
      private

      def text
        <<~TEXT
          Привет, #{athlete.user.first_name}.
          Через неделю истекает срок действия твоей [награды](#{routes.badge_url(@trophy.badge)}) за скорость. Попробуй удержать её!

          #{super}
        TEXT
      end
    end
  end
end
