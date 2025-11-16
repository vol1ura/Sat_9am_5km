# frozen_string_literal: true

module Telegram
  class Bot < ApplicationService
    TOKEN = ENV.fetch('BOT_TOKEN')
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

      begin
        response = send_request
        return if response.is_a?(Net::HTTPSuccess)

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        raise "Telegram request failed. #{parsed_body[:description]}" if parsed_body[:error_code] != 403
      rescue StandardError => e
        Rails.logger.error e.message
        (retry_count += 1) < 3 ? retry : raise
      end
    end

    private

    def uri
      @uri ||= URI("https://api.telegram.org/bot#{TOKEN}/#{@method}")
    end

    def send_request
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 60, read_timeout: 60) do |http|
        req = Net::HTTP::Post.new(uri)
        if @payload.key?(:form_data)
          req.set_form(@payload[:form_data], 'multipart/form-data')
        else
          req['Content-Type'] = 'application/json'
          req.body = @payload.to_json
        end
        http.request(req)
      end
    end
  end
end
