# frozen_string_literal: true

require 'bcrypt'

class MobilePairingCode < ApplicationRecord
  TTL = 5.minutes
  MAX_FAILED_ATTEMPTS = 5

  belongs_to :user

  validates :code_digest, :expires_at, presence: true

  scope :active, -> { where(consumed_at: nil, expires_at: Time.current..) }

  class << self
    def generate_for!(user)
      raw_code = format('%06d', SecureRandom.random_number(1_000_000))

      transaction do
        user.mobile_pairing_codes.active.update_all(consumed_at: Time.current)
        create!(
          user: user,
          code_digest: BCrypt::Password.create(raw_code),
          expires_at: TTL.from_now,
        )
      end

      raw_code
    end
  end

  def consume!(raw_code)
    with_lock do
      return false unless usable?

      if BCrypt::Password.new(code_digest).is_password?(raw_code.to_s)
        update!(consumed_at: Time.current)
        true
      else
        update!(failed_attempts: failed_attempts + 1)
        false
      end
    end
  rescue BCrypt::Errors::InvalidHash
    false
  end

  def usable?
    consumed_at.nil? && expires_at.future? && failed_attempts < MAX_FAILED_ATTEMPTS
  end
end
