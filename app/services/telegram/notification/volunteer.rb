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

        notify!(@user.telegram_id)
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

        @event.country.localized(
          'notification.volunteer_info',
          first_name: @user.first_name,
          event_name: @event.name,
          roster_link: roster_link,
          director_info: director_info,
          volunteer_role: ApplicationController.helpers.human_volunteer_role(@volunteer.role),
        )
      end

      def director_info
        return @event.country.localized('notification.common.not_yet') unless @director
        return @director.name unless @director.user&.telegram_user

        "[#{@director.user.full_name}](https://t.me/#{@director.user.telegram_user})"
      end
    end
  end
end
