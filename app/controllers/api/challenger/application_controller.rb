# frozen_string_literal: true

module API
  module Challenger
    class ApplicationController < ActionController::API
      respond_to :json
      before_action :authorize_request

      private

      def authorize_request
        got = request.headers['Authorization'].to_s.delete_prefix('Bearer ').strip
        want = Rails.application.credentials.dig(:challenger, :api_key).to_s
        if want.blank?
          render(json: { error: 'Service misconfigured' }, status: :service_unavailable)
          return
        end

        ok = got.bytesize == want.bytesize && ActiveSupport::SecurityUtils.secure_compare(got, want)
        render(json: { error: 'Unauthorized' }, status: :unauthorized) unless ok
      end
    end
  end
end
