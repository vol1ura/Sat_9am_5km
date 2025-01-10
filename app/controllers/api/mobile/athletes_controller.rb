# frozen_string_literal: true

module API
  module Mobile
    class AthletesController < ApplicationController
      before_action :find_athlete

      def info; end

      private

      def find_athlete
        code = params[:code].to_i
        raise ActiveRecord::RecordNotFound unless code.positive?

        @athlete = Athlete.find_by!(**Athlete::PersonalCode.new(code).to_params)
      end

      def athlete_params
        params.require(:athlete).permit(:club_id, :event_id)
      end
    end
  end
end
