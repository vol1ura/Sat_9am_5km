# frozen_string_literal: true

class MobileSession < ApplicationRecord
  TTL = 90.days
  TOUCH_INTERVAL = 1.hour

  audited except: %i[token_digest last_used_at]
  belongs_to :user

  validates :token_digest, :expires_at, presence: true
  validates :token_digest, uniqueness: true

  scope :active, -> { where(revoked_at: nil, expires_at: Time.current..) }

  class << self
    def issue_for!(user, device_name: nil)
      token = SecureRandom.hex(32)
      session = create!(
        user: user,
        token_digest: digest(token),
        device_name: device_name.to_s.squish.first(120).presence,
        expires_at: TTL.from_now,
        last_used_at: Time.current,
      )
      [session, token]
    end

    def authenticate(token)
      return if token.blank?

      active.find_by(token_digest: digest(token)).tap do |session|
        next unless session

        if session.last_used_at.nil? || session.last_used_at < TOUCH_INTERVAL.ago
          session.update!(last_used_at: Time.current)
        end
      end
    end

    def digest(token) = Digest::SHA256.hexdigest(token.to_s)
  end

  def revoke! = update!(revoked_at: Time.current)
end
