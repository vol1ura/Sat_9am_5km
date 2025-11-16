# frozen_string_literal: true

module Telegram
  module Notification
    class AfterReuniteJob < ApplicationJob
      queue_as :low

      def perform(user_id)
        User::Reunite.call ::User.find(user_id)
      end
    end
  end
end
