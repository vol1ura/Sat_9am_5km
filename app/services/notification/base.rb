# frozen_string_literal: true

module Notification
  class Base < ApplicationService
    include Rails.application.routes.url_helpers

    private

    def notify!(user, **)
      if user.email
        Channel::Email.deliver(user, text:, **)
      elsif user.telegram_id
        Channel::Telegram.deliver(user, text:, **)
      end
    end

    # :nocov:
    # Notification message
    def text
      raise NotImplementedError, "Method 'text' must be implemented in the final class"
    end
    # :nocov:
  end
end
