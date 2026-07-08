# frozen_string_literal: true

RSpec.describe '/metrics' do
  before do
    ENV['PROMETHEUS_USERNAME'] = 'testuser'
    ENV['PROMETHEUS_PASSWORD'] = 'testpass'
  end

  after do
    ENV['PROMETHEUS_USERNAME'] = nil
    ENV['PROMETHEUS_PASSWORD'] = nil
  end

  describe 'GET /metrics' do
    context 'when credentials are not configured' do
      before do
        ENV['PROMETHEUS_USERNAME'] = nil
        ENV['PROMETHEUS_PASSWORD'] = nil
      end

      after do
        ENV['PROMETHEUS_USERNAME'] = 'testuser'
        ENV['PROMETHEUS_PASSWORD'] = 'testpass'
      end

      it 'returns 503 Service Unavailable' do
        get metrics_path
        expect(response).to have_http_status(:service_unavailable)
      end
    end

    context 'when credentials are configured' do
      context 'when authentication fails' do
        it 'returns 401 Unauthorized' do
          get metrics_path, headers: { 'HTTP_AUTHORIZATION' => 'Basic dXNlcjpwYXNz' }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when authentication succeeds' do
        it 'returns 200 OK with text/plain content type' do
          get metrics_path, headers: basic_auth_headers
          expect(response).to have_http_status(:ok)
          expect(response.content_type).to eq('text/plain')
        end

        it 'returns metrics in Prometheus format' do
          get metrics_path, headers: basic_auth_headers
          expect(response.body).to match(/s95_.*\{.*\}\s+\d+/)
        end

        it 'caches the response' do
          expect(Rails.cache).to receive(:fetch).with('s95_metrics', { expires_in: 300 }).and_call_original
          get metrics_path, headers: basic_auth_headers
        end
      end
    end
  end

  def basic_auth_headers
    credentials = Base64.encode64('testuser:testpass').strip
    { 'HTTP_AUTHORIZATION' => "Basic #{credentials}" }
  end
end
