# frozen_string_literal: true

class WalletPassesController < ApplicationController
  def new
    prefill_from_current_user if user_signed_in? && current_user.athlete
  end

  def create
    @athlete_code = params[:athlete_code].to_s.strip
    
    if @athlete_code.blank?
      flash.now[:alert] = t('.athlete_code_required')
      return render :new, status: :unprocessable_entity
    end

    normalized_code = WalletPassGeneratorService.normalize_code(@athlete_code)
    
    athlete = Athlete.find_by(parkrun_code: normalized_code.sub(/^A/, '').to_i) || 
              Athlete.find_by(parkzhrun_code: normalized_code.sub(/^A/, '').to_i) ||
              Athlete.find_by(fiveverst_code: normalized_code.sub(/^A/, '').to_i) ||
              Athlete.find_by(runpark_code: normalized_code.sub(/^A/, '').to_i) ||
              Athlete.find_by(id: normalized_code.sub(/^A/, '').to_i)

    if athlete
      pass_data = WalletPassGeneratorService.call(
        @athlete_code,
        athlete_name: athlete.name,
        home_event_name: athlete.event&.name,
        runs_count: athlete.published_results.count,
        volunteering_count: athlete.volunteering.count,
        emergency_contact_name: athlete.user&.emergency_contact_name,
        emergency_contact_phone: athlete.user&.emergency_contact_phone
      )
    else
      pass_data = WalletPassGeneratorService.call(@athlete_code)
    end

    send_data pass_data,
              filename: "s95-#{normalized_code}.pkpass",
              type: 'application/vnd.apple.pkpass',
              disposition: 'attachment'
  rescue StandardError => e
    Rails.logger.error "WalletPassesController error: #{e.message}"
    flash.now[:alert] = t('common.error')
    render :new, status: :internal_server_error
  end

  private

  def prefill_from_current_user
    athlete = current_user.athlete
    @athlete_code = athlete.code.to_s
    @athlete_name = current_user.full_name
    @emergency_contact_name = current_user.emergency_contact_name.to_s
    @emergency_contact_phone = current_user.emergency_contact_phone.to_s
    @home_event_name = athlete.event&.name
    @runs_count = athlete.published_results.count
    @volunteering_count = athlete.volunteering.count

    # Normalize athlete code for prefill
    @athlete_code = WalletPassGeneratorService.normalize_code(@athlete_code)
  end
end
