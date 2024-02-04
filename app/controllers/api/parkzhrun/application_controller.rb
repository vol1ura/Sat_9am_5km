# frozen_string_literal: true

module API
  module Parkzhrun
    class ApplicationController < ActionController::API
      respond_to :json
      before_action :authorize_request

      private

      def authorize_request
        return if request.headers['Authorization'] == Rails.application.credentials.parkzhrun_api_key

        render json: { error: 'Token invalid' }, status: :unauthorized
      end
    end
  end
end
