# frozen_string_literal: true

module API
  module Cup
    class ApplicationController < ActionController::API
      respond_to :json
      before_action :authorize_request

      rescue_from(ActiveRecord::RecordNotFound) { head :not_found }

      private

      def authorize_request
        expected = Rails.application.credentials.dig(:cup, :api_key).to_s
        return render(json: { error: 'Service misconfigured' }, status: :service_unavailable) if expected.blank?

        supplied = request.headers['Authorization'].to_s.delete_prefix('Bearer ').strip
        return if supplied.bytesize == expected.bytesize && ActiveSupport::SecurityUtils.secure_compare(supplied, expected)

        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  end
end
