# frozen_string_literal: true

module Telegram
  module Notification
    class IncorrectRunningVolunteersJob < ApplicationJob
      queue_as :low

      def perform
        dataset.each do |volunteer|
          message = build_message(volunteer)
          [
            *::User.where(role: %i[super_admin admin]),
            *::User.protocol_responsible(volunteer.activity),
            volunteer.athlete.user,
          ]
            .compact
            .each { |user| User::Message.call(user, message) }
        end
      end

      private

      def dataset
        ::Volunteer
          .joins(:activity)
          .where(activities: { published: true, date: 3.weeks.ago.. })
          .incorrect_on_running_positions
          .includes(activity: { event: :country }, athlete: :user)
      end

      def build_message(volunteer)
        activity = volunteer.activity

        activity.country.localized(
          'notification.incorrect_running_volunteers',
          activity_id: activity.id,
          activity_date: activity.date,
          athlete_name: volunteer.name,
          athlete_code: volunteer.athlete.code,
        )
      end
    end
  end
end
