# frozen_string_literal: true

module API
  module Cup
    class ProtocolsController < ApplicationController
      def show
        activity = published_activity
        return if performed?
        return if unmodified?(activity)

        render json: protocol_json(activity)
      end

      private

      def published_activity
        event = Event.find_by!(code_name: params.expect(:event_code).to_s.downcase)
        event.activities.published.where(date: protocol_date).sole
      rescue Date::Error
        head :bad_request
      rescue ActiveRecord::SoleRecordExceeded
        render json: { error: 'Ambiguous protocol' }, status: :conflict
      end

      def protocol_date
        Date.iso8601(params[:date].to_s)
      end

      def unmodified?(activity)
        header = request.headers['If-Modified-Since']
        return false if header.blank?

        stale = activity.updated_at > Time.httpdate(header)
        head :not_modified unless stale
        !stale
      rescue ArgumentError
        head :bad_request
        true
      end

      def protocol_json(activity)
        response.headers['Last-Modified'] = activity.updated_at.httpdate
        {
          published: true,
          activity_id: activity.id,
          updated_at: activity.updated_at.iso8601,
          results: finishers(activity),
        }
      end

      def finishers(activity)
        activity.results.order(:position).filter_map do |result|
          next if result.athlete_id.nil? || result.total_time.nil?

          { athlete_id: result.athlete_id, position: result.position, total_time_sec: result.total_time }
        end
      end
    end
  end
end
