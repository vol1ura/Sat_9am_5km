# frozen_string_literal: true

module API
  module Parkzhrun
    class AthletesController < ApplicationController
      def update
        athlete = Athlete.find_by!(parkzhrun_code: params[:id])
        athlete.update!(athlete_params)
        head :ok
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error e.inspect
        render json: { errors: "Couldn't find Athlete with parkzhrun_id='#{param[:id]}'" }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        Rollbar.error(e)
        render json: { errors: e.message }, status: :unprocessable_entity
      end

      private

      def parkzhrun_athlete_params
        @parkzhrun_athlete_params ||= params.require(:athlete).permit(
          :first_name, :last_name, :patronymic, :date_of_birth, :gender,
          :city, :club, :parkrun_id, :five_verst_id
        )
      end

      def athlete_params
        options = {}
        if parkzhrun_athlete_params[:first_name] || parkzhrun_athlete_params[:last_name]
          options[:name] = "#{parkzhrun_athlete_params[:first_name]} #{parkzhrun_athlete_params[:last_name].upcase}"
        end
        options[:male] = parkzhrun_athlete_params[:gender] == 'male' if parkzhrun_athlete_params[:gender]
        # options[:parkrun_code] = parkzhrun_athlete_params[:parkrun_id] if parkzhrun_athlete_params[:parkrun_id]
        # options[:fiveverst_code] = parkzhrun_athlete_params[:five_verst_id] if parkzhrun_athlete_params[:five_verst_id]

        options
      end
    end
  end
end
