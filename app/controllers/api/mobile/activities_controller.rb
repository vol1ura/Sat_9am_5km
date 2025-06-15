# frozen_string_literal: true

module API
  module Mobile
    class ActivitiesController < ApplicationController
      before_action :find_activity!

      # Data format json:
      # { "token": string, "date": date, "results": [{ "position": number, "total_time": "MM:SS" }, ...] }
      def stopwatch
        @activity.update! params.slice(:date) unless @activity.date

        @activity.transaction do
          @activity.without_auditing do
            params[:results].each do |result_params|
              # ищем все результаты с позицией и обновляем в них время
              results = @activity.results.where result_params.slice(:position)
              if results.present?
                results.where.not(total_time: nil).update_all result_params.slice(:total_time)
              else
                @activity.results.create! result_params.slice(:position, :total_time)
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
