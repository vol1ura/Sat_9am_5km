# frozen_string_literal: true

module TelegramNotification
  class Bot < ApplicationService
    TOKEN = ENV.fetch('BOT_TOKEN')
    HEADERS = { 'Content-Type' => 'application/json' }.freeze

    def initialize(method, **payload)
      @method = method
      @payload = payload
    end

    def call
      Net::HTTP.post(
        URI("https://api.telegram.org/bot#{TOKEN}/#{@method}"),
        @payload.to_json,
        HEADERS
      ).body
    end
  end
end
