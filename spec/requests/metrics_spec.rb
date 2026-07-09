# frozen_string_literal: true

RSpec.describe '/metrics' do
  before do
    ENV['PROMETHEUS_TOKEN'] = 'test-token'
  end

  after do
    ENV['PROMETHEUS_TOKEN'] = nil
  end

  describe 'GET /metrics' do
    context 'when credentials are not configured' do
      before do
        ENV['PROMETHEUS_TOKEN'] = nil
      end

      after do
        ENV['PROMETHEUS_TOKEN'] = 'test-token'
      end

      it 'returns 503 Service Unavailable' do
        get metrics_path
        expect(response).to have_http_status(:service_unavailable)
      end
    end

    context 'when credentials are configured' do
      before do
        allow(Metrics::S95Collector).to receive(:call).and_return('s95_events_total{country="rs",active="true"} 1')
      end

      context 'when authentication fails' do
        it 'returns 401 Unauthorized' do
          get metrics_path, headers: { 'Authorization' => 'invalid-token' }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when authentication succeeds' do
        it 'returns 200 OK with text/plain content type' do
          get metrics_path, headers: auth_headers
          expect(response).to have_http_status(:ok)
          expect(response.media_type).to eq('text/plain')
        end

        it 'returns metrics in Prometheus format' do
          get metrics_path, headers: auth_headers
          expect(response.body).to match(/s95_.*\{.*\}\s+\d+/)
        end

        it 'caches the response' do
          allow(Rails.cache).to receive(:fetch).and_call_original

          get metrics_path, headers: auth_headers

          expect(Rails.cache).to have_received(:fetch).with('s95_metrics', { expires_in: 300 })
        end
      end
    end
  end

  def auth_headers
    { 'Authorization' => 'test-token' }
  end
end
