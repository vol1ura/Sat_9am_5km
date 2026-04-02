# frozen_string_literal: true

module Users
  class AuthToken
    TTL = 5.minutes

    def initialize(user)
      @user = user
    end

    def generate!
      @user.update!(auth_token: SecureRandom.hex(16), auth_token_expires_at: TTL.from_now)
    end

    def expire!
      @user.update!(auth_token: nil, auth_token_expires_at: nil)
    end

    def valid?
      @user&.auth_token && @user.auth_token_expires_at&.future?
    end
  end
end
