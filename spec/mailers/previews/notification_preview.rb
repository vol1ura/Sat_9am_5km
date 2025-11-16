# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification
class NotificationPreview < ActionMailer::Preview
  delegate :feedback, :parkzhrun_error, to: :NotificationMailer
end
