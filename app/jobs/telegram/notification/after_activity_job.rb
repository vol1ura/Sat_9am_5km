# frozen_string_literal: true

module Telegram
  module Notification
    class AfterActivityJob < ApplicationJob
      queue_as :low

      def perform(activity_id)
        activity = Activity.find activity_id
        return unless activity.published

        activity.volunteers.each { |volunteer| AfterActivity::Volunteer.call(volunteer) }
        activity.results.each { |result| AfterActivity::Result.call(result) }
      end
    end
  end
end
