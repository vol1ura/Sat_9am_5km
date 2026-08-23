# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  RECIPIENTS = [ENV.fetch('ADMIN_EMAIL'), ENV.fetch('INFO_EMAIL')].freeze

  def parkzhrun_error
    mail to: RECIPIENTS, subject: t('.parkzhrun_error')
  end

  def feedback
    @message = params[:message]
    @user_contact = params[:user_contact]
    if params[:user_id]
      @user_admin_url = admin_user_url(params[:user_id])
      user = User.find_by(id: params[:user_id])
    end

    mail to: RECIPIENTS, subject: t('.feedback'), reply_to: user&.email, &:text
  end
end
