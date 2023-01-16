# frozen_string_literal: true

# Clears rails cache
class ClearCache < ApplicationService
  CLEAR_TIME_KEY = 'cache_clear_time'
  TIME_THRESHOLD = 5.minutes.freeze

  def call
    return false if cache_clear_time && cache_clear_time > TIME_THRESHOLD.ago

    Rails.cache.clear
    Rails.cache.write(CLEAR_TIME_KEY, Time.current)
    true
  end

  private

  def cache_clear_time
    @cache_clear_time ||= Rails.cache.read(CLEAR_TIME_KEY)
  end
end
