# frozen_string_literal: true

module API
  module Mobile
    class AthletesController < ApplicationController
      before_action :find_athlete

      def info
        @history_stats =
          @athlete
            .volunteering
            .where(activity: { date: 5.months.ago.beginning_of_month.. })
            .unscope(:order)
            .group(:role, Arel.sql("date_part('month', date)"))
            .count
            .each_with_object({}) do |(k, v), h|
              h[k.first] ||= Array.new(6, 0)
              h[k.first][5 - ((Date.current.mon - k.last) % 12)] = v
            end
      end

      private

      def find_athlete
        code = params[:code].to_i
        raise ActiveRecord::RecordNotFound unless code.positive?

        @athlete = Athlete.find_by!(**Athlete::PersonalCode.new(code).to_params)
      end
    end
  end
end
