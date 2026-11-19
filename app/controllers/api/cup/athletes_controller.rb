# frozen_string_literal: true

module API
  module Cup
    class AthletesController < ApplicationController
      MAX_SEARCH = 20
      MAX_BATCH = 50

      def search
        render json: { athletes: ::Cup::AthletePayload.new(search_scope.to_a).as_json }
      end

      def batch
        render json: { athletes: ::Cup::AthletePayload.new(batch_scope.to_a).as_json }
      end

      private

      def search_scope
        query = params[:q].to_s.strip
        return Athlete.none if query.length < 2

        relation = numeric?(query) ? Athlete.where(code_params(query)) : Athlete.search_by_name(query)
        relation.includes(:event, :club).limit(MAX_SEARCH)
      end

      def batch_scope
        ids = Array(params[:ids]).filter_map { |id| Integer(id, exception: false) }.uniq.first(MAX_BATCH)
        Athlete.where(id: ids).includes(:event, :club)
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
