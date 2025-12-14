require 'sidekiq/prometheus/exporter'

Sidekiq::Prometheus::Exporter.configure do |config|
  config.server_host = '127.0.0.1'
  config.server_port = 9394
end
