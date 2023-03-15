# frozen_string_literal: true

module TelegramNotification
  module AfterActivity
    class Volunteer < Base
      private

      def text
        <<~TEXT
          Благодарим вас за волонтёрство на #{activity.number}-м забеге S95 #{activity.event.name}.
          Забеги S95 целиком зависят от вклада волонтёров, и мы очень признательны вам за помощь.
          #{super}
        TEXT
      end
    end
  end
end
