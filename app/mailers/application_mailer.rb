# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(Rails.application.credentials.mailer.user_name, 'Sat9am5km')
  layout 'mailer'
end
