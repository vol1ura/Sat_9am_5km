# frozen_string_literal: true

module API
  module Internal
    class ApplicationController < ActionController::API
      before_action :authorize_request

      private

      def authorize_request
        render json: { error: 'Forbidden' }, status: :forbidden if request.remote_ip != '127.0.0.1'
      end
    end
  end
end
