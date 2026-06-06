# frozen_string_literal: true

module Notification
  module User
    class Base < Notification::Base
      def initialize(user)
        @user = user
      end

      def call = notify @user
    end
  end
end
