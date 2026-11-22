# frozen_string_literal: true

module API
  module Mobile
    class SessionsController < ApplicationController
      before_action :authenticate_session!, only: :destroy

      def identify
        athlete = find_athlete!
        render json: {
          status: athlete.user ? 'found' : 'account_unlinked',
          athlete_code: athlete.code,
          registration_url: registration_url(athlete),
        }
      end

      def create
        athlete = find_athlete!
        unless athlete.user
          return render(
            json: { error: 'account_unlinked', registration_url: registration_url(athlete) },
            status: :unprocessable_content,
          )
        end

        pairing_code = athlete.user.mobile_pairing_codes.active.order(created_at: :desc).first
        unless pairing_code&.consume!(params.expect(:pairing_code))
          return render json: { error: 'invalid_pairing_code' }, status: :unauthorized
        end

        mobile_session, token = issue_session(athlete.user)
        render json: session_payload(athlete, mobile_session, token), status: :created
      end

      def destroy
        @mobile_session.revoke!
        head :no_content
      end

      private

      def authenticate_session!
        token = request.authorization.to_s.delete_prefix('Bearer ').presence
        @mobile_session = MobileSession.authenticate(token)
        render json: { error: 'unauthorized' }, status: :unauthorized unless @mobile_session
      end

      def issue_session(user)
        MobileSession.issue_for!(user, device_name: params[:device_name])
      end

      def session_payload(athlete, mobile_session, token)
        {
          token: token,
          expires_at: mobile_session.expires_at,
          athlete_code: athlete.code,
        }
      end

      def find_athlete!
        raw_code = params.expect(:athlete_code).to_s.delete_prefix('A').to_i
        raise ActiveRecord::RecordNotFound unless raw_code.positive?

        Athlete.find_by!(**Athlete::PersonalCode.new(raw_code).to_params)
      end

      def registration_url(athlete)
        country_code = athlete.user&.country&.code || params[:country].presence || 'ru'
        country_code = 'rs' if country_code == 'sr'
        "https://s95.#{country_code}/user"
      end
    end
  end
end
