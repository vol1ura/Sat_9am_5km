# frozen_string_literal: true

module TelegramNotification
  class AfterActivityJob < ApplicationJob
    queue_as :low

    def perform(activity_id)
      activity = Activity.find activity_id
      return unless activity.published

      activity.results.each { |result| AfterActivity::Result.call(result) }
      activity.volunteers.each { |volunteer| AfterActivity::Volunteer.call(volunteer) }
    end
  end
end
