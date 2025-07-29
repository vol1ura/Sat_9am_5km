# frozen_string_literal: true

module API
  module Mobile
    class ApplicationController < ActionController::API
      AUTHORIZATION_HEADER = "Bearer #{ENV.fetch('MOBILE_API_KEY')}".freeze

      respond_to :json
      # before_action :authorize_request
      around_action :switch_locale

      rescue_from(ActiveRecord::RecordNotFound) { head :not_found }

      private

      def switch_locale(&)
        locale = params[:locale]&.to_sym || I18n.default_locale

        I18n.with_locale(locale, &)
      end

      # def authorize_request
      #   return if request.headers['Authorization'] == AUTHORIZATION_HEADER

      #   head :unauthorized
      # end
    end
  end
end
