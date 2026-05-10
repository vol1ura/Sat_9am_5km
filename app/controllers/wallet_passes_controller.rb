# frozen_string_literal: true

class WalletPassesController < ApplicationController
  before_action :authenticate_user!

  def new
    prefill_from_current_user if current_user.athlete
  end

  def create
    athlete = current_user.athlete
    
    unless athlete
      flash[:alert] = t('.no_athlete_profile')
      return redirect_to user_path
    end

    @athlete_code = athlete.code.to_s
    normalized_code = WalletPassGeneratorService.normalize_code(@athlete_code)
    
    relevant_event = athlete.going_to_event || athlete.event
    relevant_date = Date.current.next_occurring(:saturday).to_time.change(hour: 9) if athlete.going_to_event

    pass_data = WalletPassGeneratorService.call(
      @athlete_code,
      athlete_name: athlete.name,
      home_event_name: athlete.event&.name,
      runs_count: athlete.published_results.count,
      volunteering_count: athlete.volunteering.count,
      emergency_contact_name: current_user.emergency_contact_name,
      emergency_contact_phone: current_user.emergency_contact_phone,
      latitude: relevant_event&.latitude,
      longitude: relevant_event&.longitude,
      relevant_date: relevant_date
    )

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
