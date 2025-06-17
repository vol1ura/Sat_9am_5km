# frozen_string_literal: true

RSpec.describe '/api/mobile/activities' do
  let!(:activity) { create(:activity, published: false, token: SecureRandom.uuid) }
  let(:token) { activity.token }
  let(:bearer_token) { 'valid_token' }
  let(:request!) { post api_url, params: request_params, headers: { Authorization: "Bearer #{bearer_token}" }, as: :json }

  before { stub_const('API::Mobile::ApplicationController::AUTHORIZATION_HEADER', 'Bearer valid_token') }

  describe '/stopwatch' do
    let(:api_url) { api_mobile_activities_stopwatch_url }
    let(:request_params) { { token: token, results: [{ position: 1, total_time: '00:17:42' }] } }

    context 'with valid parameters' do
      it 'creates new results if they do not exist' do
        expect { request! }.to change(activity.results, :count).by(1)
        expect(response).to have_http_status(:ok)
        expect(activity.results.last.total_time.strftime('%H:%M:%S')).to eq '00:17:42'
      end

      it 'updates existing results if total_time is nil' do
        result = create(:result, activity: activity, total_time: nil, position: 1)
        expect { request! }.not_to change(activity.results, :count)
        expect(response).to have_http_status :ok
        expect(result.reload.total_time.strftime('%H:%M:%S')).to eq '00:17:42'
      end
    end

    context 'with invalid token' do
      let(:request_params) { { token: 'invalid', results: [] } }

      it 'returns an error' do
        request!
        expect(response).to have_http_status :not_found
      end
    end

    context 'with invalid bearer token' do
      let(:bearer_token) { 'invalid_token' }
      let(:request_params) { { token: token, results: [] } }

      it 'returns an error' do
        request!
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe '/scanner' do
    let(:api_url) { api_mobile_activities_scanner_url }

    before { allow(AddAthleteToResultJob).to receive :perform_later }

    context 'with valid parameters' do
      let(:request_params) do
        {
          token: token,
          results: [
            { position: 'P1234', code: 'A123456' },
            { position: 'P5678', code: 'A789012' },
          ],
        }
      end

      it 'enqueues AddAthleteToResultJob for each result' do
        request!
        expect(AddAthleteToResultJob).to have_received(:perform_later).with(activity.id, 'A123456', 'P1234').once
        expect(AddAthleteToResultJob).to have_received(:perform_later).with(activity.id, 'A789012', 'P5678').once
        expect(response).to have_http_status :ok
      end
    end

    context 'with invalid token' do
      let(:request_params) { { token: 'invalid', results: [] } }

      it 'returns an error' do
        request!
        expect(response).to have_http_status :not_found
      end
    end
  end
end
