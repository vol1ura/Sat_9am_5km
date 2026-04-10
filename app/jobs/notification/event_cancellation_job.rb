# frozen_string_literal: true

module Notification
  class EventCancellationJob < ApplicationJob
    queue_as :sequential

    def perform(event_id)
      @event = Event.find event_id

      ::User.where(id: @event.athletes.or(@event.going_athletes).select(:user_id)).find_each do |user|
        next if user.notification_disabled? :other

        User::Message.call user, build_message(user)
      end
    end

    private

    def build_message(user)
      @event.country.localized(
        'notification.event_cancellation',
        first_name: user.first_name,
        event_name: @event.name,
        event_link: event_link,
      )
    end

    def event_link
      @event_link ||= Rails.application.routes.url_helpers.event_url(
        code_name: @event.code_name,
        host: @event.country.host,
      )
    end
  end
end
