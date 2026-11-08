# frozen_string_literal: true

RSpec.describe Metrics::Snapshot do
  let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(Rails).to receive(:cache).and_return(cache_store)
    Rails.cache.clear
  end

  after do
    Rails.cache.clear
  end

  describe '.refresh!' do
    it 'stores the latest collected metrics and timestamp' do
      allow(Metrics::S95Collector).to receive(:call).and_return('s95_events_total{country="rs",active="true"} 1')

      snapshot = described_class.refresh!

      expect(snapshot.body).to eq('s95_events_total{country="rs",active="true"} 1')
      expect(snapshot.generated_at).to be_present
      expect(Rails.cache.read(described_class::BODY_KEY)).to eq(snapshot.body)
      expect(Rails.cache.read(described_class::GENERATED_AT_KEY)).to eq(snapshot.generated_at)
    end
  end

  describe '.current' do
    it 'returns stored snapshot data' do
      Rails.cache.write(described_class::BODY_KEY, 's95_metrics_snapshot_ready 1')
      Rails.cache.write(described_class::GENERATED_AT_KEY, 1_725_000_000)

      snapshot = described_class.current

      expect(snapshot.body).to eq('s95_metrics_snapshot_ready 1')
      expect(snapshot.generated_at).to eq(1_725_000_000)
      expect(snapshot).to be_present
    end
  end
end
