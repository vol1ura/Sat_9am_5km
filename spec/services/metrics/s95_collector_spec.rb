# frozen_string_literal: true

RSpec.describe Metrics::S95Collector do
  describe '.call' do
    before do
      Rails.cache.clear
      create_list(:event, 2, active: true)
      create_list(:activity, 3, published: true)
      create_list(:result, 5, :published)
      create_list(:volunteer, 3, :published)
    end

    it 'returns metrics in Prometheus format' do
      result = described_class.call
      expect(result).to be_a(String)
      expect(result).to match(/s95_.*\{.*\}\s+\d+/)
    end

    it 'caches the result' do
      expect(Rails.cache).to receive(:fetch).with('s95_metrics', { expires_in: 300 }).and_call_original
      described_class.call
    end
  end
end
