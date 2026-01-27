RailsPerformance.setup do |config|
  config.enabled = ENV['RAILS_PERFORMANCE_ENABLED'] == 'true'

  config.redis = Redis.new url: ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/2')

  config.duration = 8.hours

  config.ignored_paths = %w[/rails/active_storage /storage /app_performance]

  config.include_rake_tasks = true

  config.custom_data_proc = proc do |env|
    request = Rack::Request.new(env)
    {
      ip: request.ip,
      user_agent: request.env['HTTP_USER_AGENT']
    }
  end
end
