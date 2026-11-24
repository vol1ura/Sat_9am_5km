# frozen_string_literal: true

module CupCredentials
  KEY = 'cup-test-key'
  SECRET = 's' * 32

  def stub_cup_credentials(api_key: KEY, sso_secret: SECRET)
    allow(Rails.application.credentials).to receive(:dig).and_wrap_original do |method, *args|
      case args
      when %i[cup api_key] then api_key
      when %i[cup sso_secret] then sso_secret
      else method.call(*args)
      end
    end
  end
end
