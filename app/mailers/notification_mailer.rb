# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  RECIPIENTS = [ENV.fetch('ADMIN_EMAIL'), ENV.fetch('INFO_EMAIL')].freeze

  def parkzhrun_error
    mail(to: RECIPIENTS, subject: t('.parkzhrun_error'))
  end

  def feedback
    @message = params[:message]
    @user_id = params[:user_id]
    mail(to: RECIPIENTS, subject: t('.feedback'), &:text)
  end

  def new_club
    @name = params[:name]
    @description = params[:description]
    @user = params[:user]
    @country_code = params[:country_code]

    if (logo = params[:logo])
      attachments[logo[:filename]] = {
        mime_type: logo[:content_type],
        content: Base64.decode64(logo[:data]),
      }
    end

    mail(to: ENV.fetch('INFO_EMAIL'), subject: t('.new_club'), &:text)
  end
end
