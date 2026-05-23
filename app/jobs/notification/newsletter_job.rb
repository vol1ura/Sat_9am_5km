# frozen_string_literal: true

module Notification
  class NewsletterJob < ApplicationJob
    queue_as :low

    def perform(newsletter_id, user_id, notification_type)
      user = ::User.find user_id
      return if user.notification_disabled? notification_type

      newsletter = ::Newsletter.find newsletter_id
      Newsletter.call newsletter, user, increment: true
    end
  end
end
