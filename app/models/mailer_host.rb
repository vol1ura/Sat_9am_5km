# frozen_string_literal: true

module MailerHost
  module_function

  def host
    Thread.current[:mailer_host]
  end

  def host=(value)
    Thread.current[:mailer_host] = value
  end
end
