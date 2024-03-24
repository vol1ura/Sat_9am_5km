# frozen_string_literal: true

module Telegram
  class Bot < ApplicationService
    TOKEN = ENV.fetch('BOT_TOKEN')
    HEADERS = { 'Content-Type' => 'application/json' }.freeze
    MAIN_KEYBOARD = {
      keyboard: [['ℹ️ QR-код', '❓ справка']],
      resize_keyboard: true,
    }.freeze

    def initialize(method, **payload)
      @method = method
      @payload = payload
    end

    def call
      Net::HTTP.post(
        URI("https://api.telegram.org/bot#{TOKEN}/#{@method}"),
        @payload.to_json,
        HEADERS,
      )
    end
  end
end
