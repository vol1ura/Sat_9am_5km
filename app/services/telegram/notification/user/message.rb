# frozen_string_literal: true

module Telegram
  module Notification
    module User
      class Message < Base
        def initialize(user, message)
          @message = message
          super(user)
        end

        private

        def text = @message
      end
    end
  end
end
