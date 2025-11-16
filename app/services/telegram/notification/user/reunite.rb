# frozen_string_literal: true

module Telegram
  module Notification
    module User
      class Reunite < Base
        private

        def text
          no_value = country.localized 'notification.common.no_value'

          country.localized(
            'notification.user.reunite',
            first_name: @user.first_name,
            full_name: @user.full_name,
            gender: athlete.gender,
            club: athlete.club&.name || no_value,
            home_event: athlete.event&.name || no_value,
            parkrun_code: athlete.parkrun_code || no_value,
            fiveverst_code: athlete.fiveverst_code || no_value,
            runpark_code: athlete.runpark_code || no_value,
          )
        end

        def athlete
          @athlete ||= @user.athlete
        end

        def country
          return @country if @country

          athlete_event = athlete.event
          athlete_event ||= (athlete.results.published.last || athlete.volunteering.last)&.activity&.event
          @country = athlete_event&.country || Country.default
        end
      end
    end
  end
end
