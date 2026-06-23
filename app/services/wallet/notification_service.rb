# frozen_string_literal: true

module Wallet
  class NotificationService < ApplicationService
    # Apple Push Notification service (APNs) endpoint
    APNS_URL = "https://api.push.apple.com/v3/device"

    param :registration, reader: :private

    def call
      return unless apns_enabled?

      uri = URI.parse("#{APNS_URL}/#{registration.push_token}")
      request = Net::HTTP::Post.new(uri)
      
      # For Apple Wallet, the body must be empty
      request.body = {}.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.cert = certificate
      http.key = private_key

      response = http.request(request)

      if response.code == '200'
        Rails.logger.info "Successfully sent push notification to device #{registration.device_library_identifier}"
      else
        Rails.logger.error "Failed to send push notification to #{registration.device_library_identifier}: #{response.body}"
        registration.destroy if response.code == '410'
      end
    end

    private

    def apns_enabled?
      File.exist?(WalletPassGeneratorService::PASS_DIR.join('pass.cer')) || 
      File.exist?(WalletPassGeneratorService::PASS_DIR.join('pass.p12'))
    end

    def certificate
      @certificate ||= WalletPassGeneratorService.new('A0').send(:certificate)
    end

    def private_key
      @private_key ||= WalletPassGeneratorService.new('A0').send(:private_key)
    end
  end
end
