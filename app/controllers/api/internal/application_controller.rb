# frozen_string_literal: true

module API
  module Internal
    class ApplicationController < ActionController::API
      before_action :authorize_request

      private

      def authorize_request
        return if request.headers['Authorization'] == Rails.application.credentials.internal_api_key

        render json: { error: 'Token invalid' }, status: :unauthorized
      end
    end
  end
end
