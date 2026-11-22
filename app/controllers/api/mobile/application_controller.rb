# frozen_string_literal: true

module API
  module Mobile
    class ApplicationController < ActionController::API
      respond_to :json
      around_action :switch_locale

      rescue_from(ActiveRecord::RecordNotFound) { head :not_found }

      rescue_from ActiveRecord::RecordInvalid do |error|
        render json: { error: 'validation_failed', details: error.record.errors.to_hash }, status: :unprocessable_content
      end

      rescue_from ActionController::ParameterMissing do |error|
        render json: { error: 'invalid_parameters', details: error.message }, status: :bad_request
      end

      private

      def switch_locale(&)
        locale = params[:locale]&.to_sym || I18n.default_locale

        I18n.with_locale(locale, &)
      end
    end
  end
end
