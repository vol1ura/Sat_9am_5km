# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  RECIPIENTS = [ENV.fetch('ADMIN_EMAIL'), ENV.fetch('INFO_EMAIL')].freeze

  def parkzhrun_error
    mail to: RECIPIENTS, subject: t('.parkzhrun_error')
  end

  def feedback
    @message = params[:message]
    @user_contact = params[:user_contact]
    @user_admin_url = admin_user_url(params[:user_id]) if params[:user_id]
    mail to: RECIPIENTS, subject: t('.feedback'), &:text
  end
end
