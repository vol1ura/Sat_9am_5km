# frozen_string_literal: true

module API
  module Mobile
    class ActivitiesController < ApplicationController
      before_action :find_activity!

      # Data format json:
      # { "token": string, "results": [{ "position": number, "total_time": "HH:MM:SS" }, ...] }
      def stopwatch
        TimerProcessingJob.perform_later @activity.id, params.expect(results: [%i[position total_time]])
        notify_volunteers('timer')
        head :ok
      end

      # Data format json:
      # { "token": string, "results": [{ "position": "P1234", "code": "A123456" }, ...] }
      def scanner
        ScannerProcessingJob.perform_later @activity.id, params.expect(results: [%i[position code]])
        notify_volunteers('scanner')
        head :ok
      end

      private

      def find_activity!
        @activity = Activity.unpublished.find_by!(token: params[:token])
      end

      def notify_volunteers(role)
        Telegram::Notification::ActivityAlertJob.perform_later(
          @activity.id,
          ['director', 'results_handler', role],
          render_to_string(partial: role, formats: :text).to_str,
        )
      end
    end
  end
end
