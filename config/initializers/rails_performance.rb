RailsPerformance.setup do |config|
  config.enabled = ENV['RAILS_PERFORMANCE_ENABLED'] == 'true'

  config.redis = Redis.new(url: ENV['REDIS_URL'].presence || 'redis://127.0.0.1:6379/2')

  config.http_basic_authentication_enabled = false

  config.ignored_endpoints = [
    'ActiveStorage::DiskController#show', 'ActiveStorage::Representations::RedirectController#show',
    'RailsPerformance::RailsPerformanceController#index', 'RailsPerformance::RailsPerformanceController#custom',
    'RailsPerformance::RailsPerformanceController#recent', 'RailsPerformance::RailsPerformanceController#slow',
    'RailsPerformance::RailsPerformanceController#requests', 'RailsPerformance::RailsPerformanceController#rake',
    'RailsPerformance::RailsPerformanceController#crashes', 'RailsPerformance::RailsPerformanceController#trace',
    'RailsPerformance::RailsPerformanceController#sidekiq', 'RailsPerformance::RailsPerformanceController#summary'
  ]
end if defined?(RailsPerformance)
