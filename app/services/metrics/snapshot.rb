# frozen_string_literal: true

module Metrics
  class Snapshot
    BODY_KEY = 's95_metrics_snapshot'
    GENERATED_AT_KEY = 's95_metrics_snapshot_generated_at'

    SnapshotData = Struct.new(:body, :generated_at, keyword_init: true) do
      def present?
        body.present? && generated_at.present?
      end
    end

    def self.refresh!
      generated_at = Time.current.to_i
      body = S95Collector.call

      Rails.cache.write(BODY_KEY, body)
      Rails.cache.write(GENERATED_AT_KEY, generated_at)

      SnapshotData.new(body:, generated_at:)
    end

    def self.current
      SnapshotData.new(
        body: Rails.cache.read(BODY_KEY),
        generated_at: Rails.cache.read(GENERATED_AT_KEY),
      )
    end
  end
end
