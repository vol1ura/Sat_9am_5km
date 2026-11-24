# frozen_string_literal: true

module API
  module Cup
    class AthletesController < ApplicationController
      MAX_SEARCH = 20

      def search
        @athletes = search_scope.to_a
        @volunteering_by_role = volunteering_by_role(@athletes.map(&:id))
      end

      private

      def search_scope
        query = params[:q].to_s.strip
        return Athlete.none if query.length < 2

        relation = numeric?(query) ? Athlete.where(code_params(query)) : Athlete.search_by_name(query)
        relation.includes(:event, :club).limit(MAX_SEARCH)
      end

      def volunteering_by_role(athlete_ids)
        return {} if athlete_ids.empty?

        counts = Hash.new { |by_athlete, athlete_id| by_athlete[athlete_id] = {} }
        grouped = Volunteer.published.where(athlete_id: athlete_ids).group(:athlete_id, :role).count
        grouped.each do |(athlete_id, role), count|
          counts[athlete_id][role_name(role)] = count
        end
        counts
      end

      def role_name(role)
        role.is_a?(Integer) ? Volunteer.roles.key(role) : role.to_s
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
