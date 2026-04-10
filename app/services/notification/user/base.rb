# frozen_string_literal: true

module Notification
  module User
    class Base < Notification::Base
      def initialize(user)
        @user = user
      end

      def call
        notify! @user if @user.email || @user.telegram_id
      rescue StandardError => e
        Rollbar.error e, user_id: @user.id
      end
    end
  end
end
