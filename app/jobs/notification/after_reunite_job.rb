# frozen_string_literal: true

module Notification
  class AfterReuniteJob < ApplicationJob
    queue_as :low

    def perform(user_id)
      user = ::User.find user_id
      return if user.notification_disabled? :other

      User::Reunite.call user
    end
  end
end
