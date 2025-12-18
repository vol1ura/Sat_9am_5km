# frozen_string_literal: true

Yabeda::Rails.install!

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Yabeda::Prometheus::Exporter.start_metrics_server!
  end
end
