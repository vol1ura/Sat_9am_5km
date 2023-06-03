# frozen_string_literal: true

module TelegramNotification
  module AfterActivity
    class Volunteer < Base
      private

      def text
        <<~TEXT
          #{athlete.user.first_name}, привет!
          Благодарим вас за волонтёрство на #{activity.number}-м забеге S95 #{activity.event_name}.
          Забеги S95 целиком зависят от вклада волонтёров, и мы очень признательны вам за помощь.
          #{super}
          С любовью,
          команда Sat9am5km.
        TEXT
      end
    end
  end
end
