# frozen_string_literal: true

Rails.application.configure do
  config.after_initialize do
    if ENV['PROMETHEUS_USERNAME'].present? && ENV['PROMETHEUS_PASSWORD'].present?
      Prometheus::Client.config = Prometheus::Client::Configuration.new
      Prometheus::Client.config.logger = Rails.logger
    end
  end
end
