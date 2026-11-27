# frozen_string_literal: true

module Cup
  module SsoToken
    module_function

    def configured?
      secret.bytesize >= 32
    end

    def secret
      Rails.application.credentials.dig(:cup, :sso_secret).to_s
    end

    def build(payload)
      raise ArgumentError, 'cup sso secret is not configured' unless configured?

      encoded = Base64.urlsafe_encode64(payload.to_json, padding: false)
      signature = Base64.urlsafe_encode64(OpenSSL::HMAC.digest('SHA256', secret, encoded), padding: false)
      Base64.urlsafe_encode64({ p: encoded, s: signature }.to_json, padding: false)
    end
  end
end
