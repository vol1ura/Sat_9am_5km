# frozen_string_literal: true

module Telegram
  module Notification
    class ClubRegisteredJob < ApplicationJob
      queue_as :low

      def perform(user_id, club_id)
        user = ::User.find user_id
        club = ::Club.find club_id

        message = club.country.localized(
          'notification.club_registered',
          first_name: user.first_name,
          club_name: club.name,
          club_url: Rails.application.routes.url_helpers.club_url(club.slug, host: club.country.host),
        )

        User::Message.call(user, message)
      end
    end
  end
end
