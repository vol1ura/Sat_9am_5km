# frozen_string_literal: true

class RenewGoingToEventJob < ApplicationJob
  queue_as :low

  def perform(event_id)
    event = Event.find event_id
    event.going_athletes.update_all going_to_event_id: nil
    return unless event.active

    Volunteer
      .joins(:activity)
      .where(activities: { date: event.timezone_object.today.next_occurring(:saturday), event_id: event_id })
      .includes(:athlete)
      .find_each do |volunteer|
        volunteer.athlete.update going_to_event_id: event_id
      end
  end
end
