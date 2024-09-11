require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module Sat9am5km
  class Application < Rails::Application
    config.time_zone = ENV.fetch("TZ", "Europe/Moscow")
    config.i18n.available_locales = %i[ru rs en]
    config.i18n.default_locale = :ru
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets capistrano tasks])

    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      **Rails.application.credentials.mailer,
      authentication: :plain,
      domain: ENV.fetch('APP_HOST'),
      enable_starttls_auto: true
    }
    config.action_mailer.preview_paths << "#{Rails.root}/spec/mailers/previews"

    config.active_storage.service = :local

    config.telegram = config_for(:telegram)
  end
end
