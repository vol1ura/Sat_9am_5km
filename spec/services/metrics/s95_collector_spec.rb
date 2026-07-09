# frozen_string_literal: true

RSpec.describe Metrics::S95Collector do
  describe '.call' do
    it 'returns metrics in Prometheus format' do
      event = create(:event, active: true)
      activity = create(:activity, event: event, published: true)
      create_list(:result, 5, activity:)
      create_list(:volunteer, 3, activity:)

      result = described_class.call

      expect(result).to be_a(String)
      expect(result).to match(/s95_.*\{.*\}\s+\d+/)
    end

    it 'defines cache ttl for metrics endpoint' do
      expect(described_class::TTL).to eq(5.minutes)
    end
  end
end
