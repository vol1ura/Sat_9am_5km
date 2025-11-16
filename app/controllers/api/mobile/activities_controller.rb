# frozen_string_literal: true

module API
  module Mobile
    class ActivitiesController < ApplicationController
      before_action :find_activity!
      before_action :check_activity_date!

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

      # Data format json:
      # {
      #   "token": string,
      #   "results": [{ "position": number, "total_time": "HH:MM:SS.MM" }, ...],
      #   "activityStartTime": timestamp
      # }
      def live
        return head :unprocessable_content unless params.key?(:results)

        results = params[:results]
        results.each { |result| result.expect(:position, :total_time) } if results.any?

        event = @activity.event
        event.update!(live_results: { results: results, start_time: params.expect(:activityStartTime) })

        event.broadcast_replace_later_to(
          "live_results_from_#{event.code_name}",
          target: 'live_results_frame',
          partial: 'events/live_results_frame',
          locals: { live_results: event.live_results },
        )

        head :ok
      end

      private

      def find_activity!
        @activity = Activity.unpublished.find_by!(token: params[:token])
      end

      def check_activity_date!
        head :unprocessable_content unless @activity.date.today?
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
