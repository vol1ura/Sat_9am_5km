# frozen_string_literal: true

module API
  module Internal
    class ApplicationController < ActionController::API
      respond_to :json
      before_action :authorize_request
      around_action :switch_locale

      rescue_from(ActiveRecord::RecordNotFound) { head :not_found }

      private

      def switch_locale(&)
        locale = params[:locale]&.to_sym || I18n.default_locale

        I18n.with_locale(locale, &)
      end

      def authorize_request
        render json: { errors: 'Forbidden' }, status: :forbidden if request.remote_ip != '127.0.0.1'
      end
    end
  end
end
