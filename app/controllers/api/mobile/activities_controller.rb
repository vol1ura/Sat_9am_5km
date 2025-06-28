# frozen_string_literal: true

module API
  module Mobile
    class ActivitiesController < ApplicationController
      before_action :find_activity!

      # Data format json:
      # { "token": string, "date": date, "results": [{ "position": number, "total_time": "HH:MM:SS" }, ...] }
      def stopwatch
        @activity.update! date: params[:date] if params[:date]
        TimerProcessingJob.perform_later @activity.id, params.expect(results: [%i[position total_time]])
        head :ok
      end

      # Data format json:
      # { "token": string, "results": [{ "position": "P1234", "code": "A123456" }, ...] }
      def scanner
        ScannerProcessingJob.perform_later @activity.id, params.expect(results: [%i[position code]])
        head :ok
      end

      private

      def find_activity!
        @activity = Activity.unpublished.find_by!(token: params[:token])
      end
    end
  end
end
