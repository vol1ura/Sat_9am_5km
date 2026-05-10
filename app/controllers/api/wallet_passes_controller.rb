# frozen_string_literal: true

module Api
  class WalletPassesController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :validate_api_token, only: [:download]
    before_action :validate_auth_token, except: [:log, :download, :registrations]

    def download
      athlete = find_athlete(params[:athlete_id])

      unless athlete
        return render json: { error: 'Athlete not found' }, status: :not_found
      end

      relevant_event = athlete.going_to_event || athlete.event
      relevant_date = Date.current.next_occurring(:saturday).to_time.change(hour: 9) if athlete.going_to_event

      pass_data = WalletPassGeneratorService.call(
        athlete.code,
        athlete_name: athlete.name,
        home_event_name: athlete.event&.name,
        runs_count: athlete.published_results.count,
        volunteering_count: athlete.volunteering.count,
        emergency_contact_name: athlete.user&.emergency_contact_name,
        emergency_contact_phone: athlete.user&.emergency_contact_phone,
        latitude: relevant_event&.latitude,
        longitude: relevant_event&.longitude,
        relevant_date: relevant_date
      )

      send_data pass_data,
                filename: "s95-#{athlete.code}.pkpass",
                type: 'application/vnd.apple.pkpass',
                disposition: 'attachment'
    end

    def register
      athlete = find_athlete_by_serial(params[:serial_number])
      
      unless athlete
        return render json: {}, status: :not_found
      end

      registration = WalletPassRegistration.find_or_initialize_by(
        device_library_identifier: params[:device_library_identifier],
        pass_type_identifier: params[:pass_type_identifier],
        serial_number: params[:serial_number]
      )
      
      registration.athlete = athlete
      registration.push_token = params[:pushToken]
      
      if registration.save
        render json: {}, status: :created
      else
        render json: {}, status: :bad_request
      end
    end

    def unregister
      registration = WalletPassRegistration.find_by(
        device_library_identifier: params[:device_library_identifier],
        pass_type_identifier: params[:pass_type_identifier],
        serial_number: params[:serial_number]
      )

      if registration&.destroy
        render json: {}, status: :ok
      else
        render json: {}, status: :not_found
      end
    end

    def registrations
      registrations = WalletPassRegistration.where(
        device_library_identifier: params[:device_library_identifier],
        pass_type_identifier: params[:pass_type_identifier]
      )

      if registrations.any?
        serial_numbers = registrations.map(&:serial_number)
        render json: { serialNumbers: serial_numbers, lastUpdated: Time.current.to_i.to_s }
      else
        render json: {}, status: :no_content
      end
    end

    def show
      athlete = find_athlete_by_serial(params[:serial_number])

      unless athlete
        return render json: {}, status: :not_found
      end

      relevant_event = athlete.going_to_event || athlete.event
      relevant_date = Date.current.next_occurring(:saturday).to_time.change(hour: 9) if athlete.going_to_event

      pass_data = WalletPassGeneratorService.call(
        athlete.code,
        athlete_name: athlete.name,
        home_event_name: athlete.event&.name,
        runs_count: athlete.published_results.count,
        volunteering_count: athlete.volunteering.count,
        emergency_contact_name: athlete.user&.emergency_contact_name,
        emergency_contact_phone: athlete.user&.emergency_contact_phone,
        latitude: relevant_event&.latitude,
        longitude: relevant_event&.longitude,
        relevant_date: relevant_date
      )

      send_data pass_data,
                filename: 'pass.pkpass',
                type: 'application/vnd.apple.pkpass',
                disposition: 'attachment'
    end

    def log
      Rails.logger.warn "Apple Wallet Log: #{params[:logs]}"
      render json: {}, status: :ok
    end

    private

    def find_athlete(id_or_code)
      id = id_or_code.to_s.sub(/^A/, '').to_i
      Athlete.where(parkrun_code: id)
             .or(Athlete.where(parkzhrun_code: id))
             .or(Athlete.where(fiveverst_code: id))
             .or(Athlete.where(runpark_code: id))
             .or(Athlete.where(id: id))
             .first
    end

    def find_athlete_by_serial(serial)
      athlete_code = serial.split('-')[1]
      return nil unless athlete_code
      find_athlete(athlete_code)
    end

    def validate_api_token
      token = request.headers['X-Wallet-API-Token']
      expected_token = ENV['WALLET_API_TOKEN']
      
      if expected_token.blank? || token != expected_token
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end

    def validate_auth_token
      auth_header = request.headers['Authorization']
      unless auth_header&.start_with?('ApplePass ')
        return render json: {}, status: :unauthorized
      end

      token = auth_header.sub('ApplePass ', '')
      registration = WalletPassRegistration.find_by(
        serial_number: params[:serial_number],
        auth_token: token
      )

      unless registration
        return render json: {}, status: :unauthorized
      end
    end
  end
end
