# frozen_string_literal: true

class AutoCreateActivitiesJob < ApplicationJob
  queue_as :low

  UPCOMING_SATURDAYS_COUNT = 4

  def perform
    Event.active.where(auto_create_activities: true).find_each do |event|
      (0...UPCOMING_SATURDAYS_COUNT).each do |k|
        date = Time.zone.today.next_occurring(:saturday).advance(weeks: k)
        event.activities.find_or_create_by!(date:)
      end
    end
  end
end
