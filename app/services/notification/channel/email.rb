# frozen_string_literal: true

module Notification
  module Channel
    class Email
      def self.deliver(user, text:, **)
        html = ::Notification::MarkdownConverter.to_html text
        retry_count = 0

        begin
          UserNotificationMailer.notify(user, html).deliver_now
        rescue Net::OpenTimeout, Net::ReadTimeout
          (retry_count += 1) < 3 ? retry : raise
        end
      end
    end
  end
end
