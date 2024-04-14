require "active_support/core_ext/integer/time"

Rails.application.configure do
  if ENV["BULLET_ENABLED"] == "true"
    config.after_initialize do
      Bullet.enable        = true
      # Bullet.alert         = true
      Bullet.bullet_logger = true
      Bullet.console       = true
      Bullet.rails_logger  = true
      Bullet.add_footer    = true
    end
  end
  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  config.hosts << /application\.local\.\w{2}/

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.hours.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.action_mailer.default_url_options = { host: 'localhost:3000', protocol: 'http' }
  config.action_mailer.perform_caching = false

  # Print deprecation notices to stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  config.logger = Logger.new('log/development.log', 3, 1.megabytes)

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  config.generators do |g|
    g.test_framework :rspec
  end

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true
end
