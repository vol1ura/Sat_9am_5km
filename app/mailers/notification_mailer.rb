# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def parkzhrun_error
    mail(to: [ENV.fetch('ADMIN_EMAIL'), ENV.fetch('INFO_EMAIL')], subject: t('.parkzhrun_error'))
  end

  def feedback
    @message = params[:message]
    @user_id = params[:user_id]
    mail(to: ENV.fetch('ADMIN_EMAIL'), subject: t('.feedback'))
  end
end
