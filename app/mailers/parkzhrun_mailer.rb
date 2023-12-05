# frozen_string_literal: true

class ParkzhrunMailer < ApplicationMailer
  RECIPIENTS = [ENV.fetch('ADMIN_EMAIL'), ENV.fetch('INFO_EMAIL')].freeze

  def success
    mail(to: RECIPIENTS, subject: t('.success'))
  end

  def error
    mail(to: RECIPIENTS, subject: t('.error'))
  end
end
