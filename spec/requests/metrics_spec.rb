# frozen_string_literal: true

RSpec.describe '/metrics' do
  let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

  before do
    allow(Rails).to receive(:cache).and_return(cache_store)
    ENV['PROMETHEUS_TOKEN'] = 'test-token'
    Rails.cache.clear
  end

  after do
    ENV['PROMETHEUS_TOKEN'] = nil
    Rails.cache.clear
  end

  describe 'GET /metrics' do
    context 'when credentials are not configured' do
      before do
        ENV['PROMETHEUS_TOKEN'] = nil
      end

      it 'returns 404 Not Found' do
        get metrics_path

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when authentication fails' do
      it 'returns 401 Unauthorized' do
        get metrics_path, headers: { 'Authorization' => 'invalid-token' }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authentication succeeds' do
      it 'accepts Prometheus bearer authorization' do
        get metrics_path, headers: { 'Authorization' => 'Bearer test-token' }

        expect(response).to have_http_status(:ok)
      end

      it 'accepts raw token authorization' do
        get metrics_path, headers: { 'Authorization' => 'test-token' }

        expect(response).to have_http_status(:ok)
      end

      it 'returns text/plain content type' do
        get metrics_path, headers: auth_headers

        expect(response.media_type).to eq('text/plain')
      end

      it 'returns an empty snapshot state without collecting metrics' do
        allow(Metrics::S95Collector).to receive(:call)

        get metrics_path, headers: auth_headers

        expect(response.body).to include('s95_metrics_snapshot_ready 0')
        expect(response.body).to include('s95_metrics_generated_at_seconds 0')
        expect(response.body).to include('s95_metrics_snapshot_age_seconds 0')
        expect(Metrics::S95Collector).not_to have_received(:call)
      end

      it 'returns the latest metrics snapshot' do
        Rails.cache.write(Metrics::Snapshot::BODY_KEY, 's95_events_total{country="rs",active="true"} 1')
        Rails.cache.write(Metrics::Snapshot::GENERATED_AT_KEY, 1.hour.ago.to_i)

        get metrics_path, headers: auth_headers

        expect(response.body).to include('s95_metrics_snapshot_ready 1')
        expect(response.body).to include('s95_events_total{country="rs",active="true"} 1')
      end
    end
  end

  def auth_headers
    { 'Authorization' => 'Bearer test-token' }
  end
end
