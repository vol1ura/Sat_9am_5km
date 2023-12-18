# frozen_string_literal: true

module API
  module Internal
    class AthletesController < ApplicationController
      def update
        @athlete = Athlete.joins(:user).where(user: { telegram_id: params[:telegram_id] }).take!

        if @athlete.update(athlete_params)
          head :ok
        else
          render json: { errors: @athlete.errors.full_messages }, status: :unprocessable_entity
        end
      end

      rescue_from(ActiveRecord::InvalidForeignKey) { head :not_acceptable }

      private

      def athlete_params
        params.require(:athlete).permit(:club_id, :event_id)
      end
    end
  end
end
