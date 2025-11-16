RailsPerformance.setup do |config|
  config.enabled = ENV['RAILS_PERFORMANCE_ENABLED'] == 'true'

  config.redis = Redis.new url: ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/2')

  config.http_basic_authentication_enabled = false

  config.ignored_paths = %w[/rails/active_storage /storage /app_performance]

  config.custom_data_proc = proc do |env|
    { user_agent: Rack::Request.new(env).env['HTTP_USER_AGENT'] }
  end
end if defined?(RailsPerformance)
