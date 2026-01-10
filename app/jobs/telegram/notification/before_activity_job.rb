# frozen_string_literal: true

module Telegram
  module Notification
    class BeforeActivityJob < ApplicationJob
      queue_as :low
      discard_on(StandardError) { |_, e| Rollbar.error e }

      def perform
        Event.find_each do |event|
          event_time = event.timezone_object.now

          VolunteerJob.set(wait_until: event_time.change(hour: 18)).perform_later(event.id)
          RenewGoingToEventJob.set(wait_until: event_time.tomorrow.change(hour: 9)).perform_later(event.id)
        end
      end
    end
  end
end
