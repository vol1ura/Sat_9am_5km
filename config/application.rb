require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
# require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require 'action_mailbox/engine'
# require 'action_text/engine'
require 'action_view/railtie'
# require 'action_cable/engine'

Bundler.require(*Rails.groups)

module KuzminkiRun
  class Application < Rails::Application
    config.time_zone = ENV.fetch('TZ', 'Europe/Moscow')
    config.i18n.default_locale = :ru
    config.load_defaults 7.0

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: ENV.fetch('SMTP_SERVER'),
      port: 587,
      authentication: :plain,
      user_name: Rails.application.credentials.dig(:mailer, :user_name),
      password: Rails.application.credentials.dig(:mailer, :password),
      domain: ENV.fetch('APP_DOMAIN'),
      enable_starttls_auto: true
    }
  end
end
