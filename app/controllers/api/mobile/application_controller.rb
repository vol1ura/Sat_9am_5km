# frozen_string_literal: true

module API
  module Mobile
    class ApplicationController < ActionController::API
      respond_to :json
      around_action :switch_locale

      rescue_from(ActiveRecord::RecordNotFound) { head :not_found }

      private

      def switch_locale(&)
        locale = params[:locale]&.to_sym || I18n.default_locale

        I18n.with_locale(locale, &)
      end
    end
  end
end
