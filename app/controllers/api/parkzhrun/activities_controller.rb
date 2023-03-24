# frozen_string_literal: true

module API
  module Parkzhrun
    class ActivitiesController < ApplicationController
      def create
        ::Parkzhrun::ActivityCreator.call(Date.parse(params[:date]))
        head :created
      rescue StandardError => e
        Rollbar.error e
        render json: { error: "Can't create activity" }, status: :unprocessable_entity
      end
    end
  end
end
