# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(ENV.fetch('EMAIL_FROM'), 'Sat9am5km')
  layout 'mailer'
end
