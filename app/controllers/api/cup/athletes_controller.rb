# frozen_string_literal: true

module API
  module Cup
    class AthletesController < ApplicationController
      MAX_SEARCH = 20
      MAIN_ROLES = Volunteer.roles.keys - %w[other]

      def search
        @athletes = search_scope.to_a
        zero_run_ids = @athletes.filter_map { |athlete| athlete.id if athlete.stats.dig('results', 'count').to_i.zero? }
        @main_role_counts =
          if zero_run_ids.empty?
            {}
          else
            Volunteer.published.where(athlete_id: zero_run_ids, role: MAIN_ROLES).group(:athlete_id).count
          end
      end

      private

      def search_scope
        query = params[:q].to_s.strip
        return Athlete.none if query.length < 2

        relation = numeric?(query) ? Athlete.where(code_params(query)) : Athlete.search_by_name(query)
        relation.includes(:event, :club).limit(MAX_SEARCH)
      end

      def numeric?(query)
        query.match?(/\A\d{3,}\z/)
      end

      def code_params(query)
        Athlete::PersonalCode.new(query.to_i).to_params
      end
    end
  end
end
