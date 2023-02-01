# frozen_string_literal: true

class ParkzhrunMailer < ApplicationMailer
  RECIPIENTS = ENV['PARKZHRUN_MAILER_RECEPIENTS'].to_s.split(',').freeze

  def success
    mail(to: RECIPIENTS, subject: t('.success'))
  end

  def error
    mail(to: RECIPIENTS, subject: t('.error'))
  end
end
