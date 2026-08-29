# frozen_string_literal: true

class MetricsController < ApplicationController
  before_action :authenticate

  def show
    render plain: metrics_data, content_type: 'text/plain; charset=utf-8'
  end

  private

  def authenticate
    unless token_configured?
      head :not_found
      return
    end

    return if authorized?

    head :unauthorized
  end

  def token_configured?
    ENV['PROMETHEUS_TOKEN'].present?
  end

  def metrics_data
    snapshot = Metrics::Snapshot.current
    generated_at = snapshot.generated_at.to_i
    ready = snapshot.present? ? 1 : 0
    age = generated_at.positive? ? Time.current.to_i - generated_at : 0

    [
      "s95_metrics_snapshot_ready #{ready}",
      "s95_metrics_generated_at_seconds #{generated_at}",
      "s95_metrics_snapshot_age_seconds #{age}",
      snapshot.body,
    ].compact.join("\n")
  end

  def authorized?
    token = ENV.fetch('PROMETHEUS_TOKEN')
    auth_header = request.headers['Authorization'].to_s

    secure_token?(auth_header, "Bearer #{token}") || secure_token?(auth_header, token)
  end

  def secure_token?(provided, expected)
    ActiveSupport::SecurityUtils.secure_compare(provided, expected)
  rescue ArgumentError
    false
  end
end
