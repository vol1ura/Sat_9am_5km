# frozen_string_literal: true

module API
  module Challenger
    class AthletesController < ApplicationController
      MAX_IDS = 100

      def latest_runs
        ids = integer_ids
        return render(json: { error: 'too many ids' }, status: :unprocessable_content) if ids.size > MAX_IDS

        @runs = Result.latest_published_for(ids)
      end

      private

      def integer_ids
        Array(params[:ids]).filter_map { |raw| Integer(raw, exception: false) }
      end
    end
  end
end
