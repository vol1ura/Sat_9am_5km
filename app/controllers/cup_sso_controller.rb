# frozen_string_literal: true

class CupSsoController < ApplicationController
  before_action :authenticate_user!

  def show
    athlete = Athlete.includes(:event).find_by(user_id: current_user.id)
    return redirect_to(root_path, alert: t('cup_sso.missing_athlete')) unless athlete
    return head(:service_unavailable) unless ::Cup::SsoToken.configured?

    callback = ::Cup::CallbackUrl.parse(params[:return_to])
    redirect_to callback.with_token(::Cup::SsoToken.build(payload_for(athlete)), state), allow_other_host: true
  end

  private

  def payload_for(athlete)
    {
      user_id: current_user.id,
      athlete_id: athlete.id,
      athlete_code: athlete.code,
      name: athlete.name,
      gender: athlete.gender,
      home_event_code: athlete.event&.code_name,
      is_admin: current_user.admin?,
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
