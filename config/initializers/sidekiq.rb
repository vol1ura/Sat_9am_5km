# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.capsule('single-threaded') do |capsule|
    capsule.concurrency = 1
    capsule.queues = %w[sequential]
  end
end
