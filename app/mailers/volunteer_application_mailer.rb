# frozen_string_literal: true

class VolunteerApplicationMailer < ApplicationMailer
  def approved
    @application = params[:application]
    @athlete = @application.athlete
    @activity = @application.activity
    @role = I18n.t("activerecord.attributes.volunteer.roles.#{@application.role}")
    mail(to: @athlete.user.email, subject: t('.subject', role: @role))
  end

  def rejected
    @application = params[:application]
    @athlete = @application.athlete
    @activity = @application.activity
    @role = I18n.t("activerecord.attributes.volunteer.roles.#{@application.role}")
    mail(to: @athlete.user.email, subject: t('.subject', role: @role))
  end
end
