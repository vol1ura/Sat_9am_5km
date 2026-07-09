# frozen_string_literal: true

class MetricsController < ApplicationController
  before_action :authenticate

  def show
    render plain: metrics_data, content_type: 'text/plain; charset=utf-8'
  end

  private

  def authenticate
    unless token_configured?
      head :service_unavailable
      return
    end

    return if ActiveSupport::SecurityUtils.secure_compare(
      request.headers['Authorization'].to_s,
      ENV.fetch('PROMETHEUS_TOKEN'),
    )

    head :unauthorized
  end

  def token_configured?
    ENV['PROMETHEUS_TOKEN'].present?
  end

  def metrics_data
    Rails.cache.fetch('s95_metrics', expires_in: Metrics::S95Collector::TTL) do
      Metrics::S95Collector.call
    end
  end
end
