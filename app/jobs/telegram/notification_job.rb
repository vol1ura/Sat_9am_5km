# frozen_string_literal: true

module Telegram
  class NotificationJob < ApplicationJob
    queue_as :low

    def perform(activity)
      return unless activity.published

      activity.results.each { |result| Informer::Result.call(result) }
      activity.volunteers.each { |volunteer| Informer::Volunteer.call(volunteer) }
    end
  end
end
