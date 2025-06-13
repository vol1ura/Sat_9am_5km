# frozen_string_literal: true

module Telegram
  module Notification
    class VolunteerJob < ApplicationJob
      queue_as :low

      def perform(event_id)
        event = Event.find(event_id)
        return unless event.active

        activity = event.activities.find_by(date: event.timezone_object.today.next_occurring(:saturday))
        return unless activity

        director = activity.volunteers.find_by(role: :director)&.athlete&.user

        activity.volunteers.includes(athlete: :user, activity: :event).find_each do |volunteer|
          User::Volunteer.call volunteer, director, event
        end
      end
    end
  end
end
