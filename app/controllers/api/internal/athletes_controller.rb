# frozen_string_literal: true

module API
  module Internal
    class AthletesController < ApplicationController
      def update
        athlete = Athlete.joins(:user).find_by!(user: { telegram_id: params[:telegram_id] })
        athlete.update!(athlete_params)
        head :ok
      end

      rescue_from(ActiveRecord::InvalidForeignKey) { head :not_acceptable }

      private

      def athlete_params
        params.require(:athlete).permit(:club_id, :event_id)
      end
    end
  end
end
