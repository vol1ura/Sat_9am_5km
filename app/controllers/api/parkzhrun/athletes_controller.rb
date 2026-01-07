# frozen_string_literal: true

module API
  module Parkzhrun
    class AthletesController < ApplicationController
      def update
        athlete = Athlete.find_by!(parkzhrun_code: params[:id])
        athlete.update!(athlete_params)
        head :ok
      rescue ActiveRecord::RecordNotFound => e
        logger.error e.inspect
        render json: { errors: "Couldn't find Athlete with parkzhrun_id='#{params[:id]}'" }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        Rollbar.error e
        render json: { errors: e.message }, status: :unprocessable_content
      end

      private

      def parkzhrun_athlete_params
        @parkzhrun_athlete_params ||= params.expect(
          athlete: %i[first_name last_name patronymic date_of_birth gender city club parkrun_id five_verst_id],
        )
      end

      def athlete_params
        options = {}
        if parkzhrun_athlete_params[:first_name]
          options[:name] = "#{parkzhrun_athlete_params[:first_name]} #{parkzhrun_athlete_params[:last_name].upcase}"
        end
        options[:gender] = parkzhrun_athlete_params[:gender] if parkzhrun_athlete_params[:gender]
        if (parkrun_code = parkzhrun_athlete_params[:parkrun_id]) && !Athlete.exists?(parkrun_code:)
          options[:parkrun_code] = parkrun_code
        end
        if (fiveverst_code = parkzhrun_athlete_params[:five_verst_id]) && !Athlete.exists?(fiveverst_code:)
          options[:fiveverst_code] = fiveverst_code
        end

        options
      end
    end
  end
end
