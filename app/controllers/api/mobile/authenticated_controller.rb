# frozen_string_literal: true

module API
  module Mobile
    class AuthenticatedController < ApplicationController
      before_action :authenticate_mobile_session!

      attr_reader :current_mobile_session, :current_user

      private

      def manageable_activities
        Activity.unpublished.where(date: 2.weeks.ago.to_date..)
      end

      def authenticate_mobile_session!
        token = request.authorization.to_s.delete_prefix('Bearer ').presence
        @current_mobile_session = MobileSession.authenticate(token)
        @current_user = @current_mobile_session&.user
        render json: { error: 'unauthorized' }, status: :unauthorized unless @current_user
      end
    end
  end
end
