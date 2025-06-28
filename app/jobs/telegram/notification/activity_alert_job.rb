# frozen_string_literal: true

module Telegram
  module Notification
    class ActivityAlertJob < ApplicationJob
      queue_as :low

      NOTIFIED_ROLES = %i[director results_handler].freeze

      def perform(activity_id, message)
        ::Volunteer.where(activity_id: activity_id, role: NOTIFIED_ROLES).includes(athlete: :user).find_each do |volunteer|
          User::Message.call volunteer.athlete.user, message
        end
      end
    end
  end
end
