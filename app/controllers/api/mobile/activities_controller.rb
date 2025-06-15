# frozen_string_literal: true

module API
  module Mobile
    class ActivitiesController < ApplicationController
      before_action :find_activity!

      # Data format json:
      # { "token": string, "date": date, "results": [{ "position": number, "total_time": "HH:MM:SS" }, ...] }
      def stopwatch
        @activity.transaction do
          @activity.without_auditing do
            params[:results].each do |result_params|
              results = @activity.results.where position: result_params[:position]
              if results.empty?
                @activity.results.create! position: result_params[:position], total_time: result_params[:total_time]
              else
                results.where(total_time: nil).update_all total_time: result_params[:total_time]
              end
            end
          end
        end

        head :ok
      end

      # Data format json:
      # { "token": string, "results": [{ "position": "P1234", "code": "A123456" }, ...] }
      def scanner
        params[:results].each do |result_params|
          AddAthleteToResultJob.perform_later @activity.id, *result_params.values_at(:code, :position)
        end

        head :ok
      end

      private

      def find_activity!
        @activity = Activity.unpublished.find_by!(token: params[:token])
      end
    end
  end
end
