# frozen_string_literal: true

module Telegram
  module Notification
    class Volunteer < Base
      def initialize(volunteer, director, event)
        @volunteer = volunteer
        @director = director
        @event = event
        @user = volunteer.athlete.user
      end

      def call
        return unless @user&.telegram_id

        notify(@user.telegram_id)
      rescue StandardError => e
        Rollbar.error e, user_id: @user.id, volunteer_id: @volunteer.id
      end

      private

      def text
        roster_link = volunteering_event_url(
          code_name: @event.code_name,
          activity_id: @volunteer.activity_id,
          host: @event.country.host,
        )

        <<~TEXT
          #{@user.first_name}, добрый вечер!

          Мы благодарны, что вы согласились быть волонтёром завтра на забеге S95.
          Пожалуйста, приходите заранее и одевайтесь по погоде.

          *Забег:* [#{@event.name}](#{roster_link})
          *Директор:* #{director_info}
          *Ваша позиция:* #{ApplicationController.helpers.human_volunteer_role @volunteer.role}

          Если у вас изменились обстоятельства или вы обнаружили неточность, сообщите, пожалуйста, директору либо в чат забега.

          С уважением,
          команда S95
        TEXT
      end

      def director_info
        return 'пока нет' unless @director
        return @director.name unless @director.user&.telegram_user

        "[#{@director.user.full_name}](https://t.me/#{@director.user.telegram_user})"
      end
    end
  end
end
