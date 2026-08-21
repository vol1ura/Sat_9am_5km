# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(Rails.application.credentials.mailer.user_name, 'S95')
  layout 'mailer'

  before_action :set_url_host

  private

  def set_url_host
    @url_host = params[:host].presence
  end

  def default_url_options
    return super unless @url_host

    super.merge(host: @url_host)
  end

  def email(user)
    Rails.env.production? ? user.email : ENV.fetch('ADMIN_EMAIL')
  end
end
