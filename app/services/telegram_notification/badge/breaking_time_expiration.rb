# frozen_string_literal: true

module TelegramNotification
  module Badge
    class BreakingTimeExpiration < Base
      private

      def text
        <<~TEXT
          Привет, #{athlete.user.first_name}.
          Через неделю истекает срок действия вашей [награды](#{routes.badge_url(@trophy.badge)}) за скорость.
          Попробуйте удержать её!

          #{super}
        TEXT
      end
    end
  end
end
