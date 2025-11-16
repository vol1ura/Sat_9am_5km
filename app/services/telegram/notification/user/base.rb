# frozen_string_literal: true

module Telegram
  module Notification
    module User
      class Base < Notification::Base
        def initialize(user)
          @user = user
        end

        def call
          return unless @user&.telegram_id

          notify!(@user.telegram_id)
        rescue StandardError => e
          Rollbar.error e, user_id: @user.id
        end
      end
    end
  end
end
