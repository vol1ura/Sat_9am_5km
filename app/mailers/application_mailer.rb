# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(
    Rails.application.credentials.dig(:mailer, :user_name) || ENV.fetch('INFO_EMAIL'),
    'S95',
  )
  layout 'mailer'
end
