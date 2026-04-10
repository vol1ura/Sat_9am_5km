# frozen_string_literal: true

module Notification
  module Channel
    class Email
      def self.deliver(user, text:, **)
        html = ::Notification::MarkdownConverter.to_html(text)
        UserNotificationMailer.notify(user, html).deliver_later
      end
    end
  end
end
