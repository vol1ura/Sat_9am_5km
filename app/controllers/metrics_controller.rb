# frozen_string_literal: true

class MetricsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate

  def show
    render plain: metrics_data, content_type: 'text/plain; charset=utf-8'
  end

  private

  def authenticate
    unless credentials_configured?
      head :service_unavailable
      return
    end

    authenticate_or_request_with_http_basic do |username, password|
      username == ENV.fetch('PROMETHEUS_USERNAME') && password == ENV.fetch('PROMETHEUS_PASSWORD')
    end
  end

  def credentials_configured?
    ENV['PROMETHEUS_USERNAME'].present? && ENV['PROMETHEUS_PASSWORD'].present?
  end

  def metrics_data
    Rails.cache.fetch('s95_metrics', expires_in: Metrics::S95Collector::TTL) do
      Metrics::S95Collector.call
    end
  end
end
