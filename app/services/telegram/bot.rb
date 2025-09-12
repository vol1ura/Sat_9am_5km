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
      retry_count = 0
      uri = URI("https://api.telegram.org/bot#{TOKEN}/#{@method}")

      begin
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 60, read_timeout: 60) do |http|
          http.post(uri, @payload.to_json, HEADERS)
        end

        raise "Notification failed. Response: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
      rescue StandardError => e
        Rails.logger.error "Notification failed. Response: #{e.message}"
        (retry_count += 1) < 3 ? retry : raise
      end
    end
  end
end
