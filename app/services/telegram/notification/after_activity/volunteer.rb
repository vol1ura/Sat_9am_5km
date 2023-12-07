# frozen_string_literal: true

module Telegram
  module Notification
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
            команда S95.
          TEXT
        end
      end
    end
  end
end
