# frozen_string_literal: true

class CupSsoController < ApplicationController
  CALLBACK_PATH = '/api/v1/auth/s95/callback'
  ALLOWED_TOP_LEVEL_DOMAINS = %i[ru rs by kz].freeze

  prepend_before_action :ensure_configured!
  before_action :authenticate_user!

  def show
    athlete = Athlete.includes(:event).find_by(user_id: current_user.id)
    return redirect_to(root_path, alert: t('cup_sso.missing_athlete')) unless athlete

    token = ::Cup::SsoToken.build(payload_for(athlete))
    redirect_to callback_url(token), allow_other_host: true
  end

  private

  def ensure_configured!
    return if ::Cup::SsoToken.configured? && ALLOWED_TOP_LEVEL_DOMAINS.include?(top_level_domain)

    render_not_found
  end

  def callback_url(token)
    query = URI.encode_www_form(token:, state:)
    base =
      Rails.application.credentials.dig(:cup, :urls, top_level_domain) ||
      Rails.application.credentials.dig(:cup, :url)

    if base.present?
      root = base.to_s.end_with?('/') ? base : "#{base}/"
      URI.join(root, "#{CALLBACK_PATH}?#{query}").to_s
    else
      URI::HTTPS.build(
        host: "cup.s95.#{top_level_domain}",
        path: CALLBACK_PATH,
        query: query,
      ).to_s
    end
  end

  def payload_for(athlete)
    {
      user_id: current_user.id,
      athlete_id: athlete.id,
      name: athlete.name,
      gender: athlete.gender,
      home_event_code: athlete.event&.code_name,
      jti: SecureRandom.uuid,
      state: state,
      exp: 60.seconds.from_now.to_i,
    }
  end

  def state
    @state ||= params[:state].to_s.tap do |value|
      raise ActionController::BadRequest unless value.match?(/\A[0-9a-f]{32,128}\z/)
    end
  end
end
