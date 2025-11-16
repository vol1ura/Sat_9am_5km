# frozen_string_literal: true

module Telegram
  module Notification
    class ActivityAlertJob < ApplicationJob
      queue_as :low

      def perform(activity_id, notified_roles, message)
        ::Volunteer
          .where(activity_id: activity_id, role: notified_roles)
          .includes(athlete: :user)
          .find_each do |volunteer|
            User::Message.call volunteer.athlete.user, message
          end
      end
    end
  end
end
