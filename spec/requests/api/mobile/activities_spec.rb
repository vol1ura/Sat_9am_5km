# frozen_string_literal: true

RSpec.describe '/api/mobile/activities' do
  let!(:activity) { create(:activity, published: false, token: SecureRandom.uuid) }
  let(:token) { activity.token }
  let(:bearer_token) { 'valid_token' }

  before { stub_const('API::Mobile::ApplicationController::AUTHORIZATION_HEADER', 'Bearer valid_token') }

  describe '/stopwatch' do
    before do
      allow(TimerProcessingJob).to receive :perform_later
      post(
        api_mobile_activities_stopwatch_url,
        params: request_params,
        headers: { Authorization: "Bearer #{bearer_token}" },
        as: :json,
      )
    end

    context 'with valid parameters' do
      let(:request_params) { { token: token, results: [{ position: 1, total_time: '00:17:42' }] } }

      it 'schedules processing job' do
        expect(TimerProcessingJob).to have_received(:perform_later).once
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid token' do
      let(:request_params) { { token: 'invalid', results: [] } }

      it 'returns an error' do
        expect(response).to have_http_status :not_found
      end
    end

    context 'with invalid bearer token' do
      let(:bearer_token) { 'invalid_token' }
      let(:request_params) { { token: token, results: [] } }

      it 'returns an error' do
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe '/scanner' do
    let(:request_params) do
      {
        token: token,
        results: [
          { position: 'P1234', code: 'A123456' },
          { position: 'P5678', code: 'A789012' },
        ],
      }
    end

    before do
      allow(ScannerProcessingJob).to receive :perform_later
      post(
        api_mobile_activities_scanner_url,
        params: request_params,
        headers: { Authorization: "Bearer #{bearer_token}" },
        as: :json,
      )
    end

    it 'enqueues ScannerProcessingJob for results' do
      expect(ScannerProcessingJob).to have_received(:perform_later).with(activity.id, be_an(Array)).once
      expect(response).to have_http_status :ok
    end

    context 'with invalid token' do
      let(:token) { 'invalid' }

      it 'returns an error' do
        expect(response).to have_http_status :not_found
      end
    end
  end
end
