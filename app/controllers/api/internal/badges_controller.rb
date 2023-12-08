# frozen_string_literal: true

module API
  module Internal
    class BadgesController < ApplicationController
      def refresh_home_badges
        HomeBadgeAwardingJob.perform_later

        head :created
      end
    end
  end
end
