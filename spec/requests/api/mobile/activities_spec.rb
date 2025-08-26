# frozen_string_literal: true

RSpec.describe '/api/mobile/activities' do
  let!(:activity) { create(:activity, published: false, token: SecureRandom.uuid, date: activity_date) }
  let(:activity_date) { Date.current }
  let(:token) { activity.token }

  describe '/stopwatch' do
    before do
      allow(TimerProcessingJob).to receive :perform_later
      post(api_mobile_activities_stopwatch_url, params: request_params, as: :json)
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

      it { expect(response).to have_http_status :not_found }
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
      post(api_mobile_activities_scanner_url, params: request_params, as: :json)
    end

    it 'enqueues ScannerProcessingJob for results' do
      expect(ScannerProcessingJob).to have_received(:perform_later).with(activity.id, be_an(Array)).once
      expect(response).to have_http_status :ok
    end

    context 'with invalid token' do
      let(:token) { 'invalid' }

      it { expect(response).to have_http_status :not_found }
    end
  end

  describe '/live' do
    let(:request_params) do
      { token: token, results: [{ position: 1, total_time: '00:17:42' }], activityStartTime: Time.current.to_i }
    end

    before { post(api_mobile_activities_live_url, params: request_params, as: :json) }

    it 'schedules processing job' do
      expect(response).to have_http_status(:ok)
      expect(activity.reload.event.live_results).to include(
        'results' => [{ 'position' => 1, 'total_time' => '00:17:42' }],
        'start_time' => a_kind_of(Integer),
      )
    end

    context 'when activity is not today' do
      let(:activity_date) { Date.yesterday }

      it { expect(response).to have_http_status :unprocessable_content }
    end

    context 'when results are not present' do
      let(:request_params) { { token: } }

      it { expect(response).to have_http_status :unprocessable_content }
    end

    context 'with invalid token' do
      let(:token) { 'invalid' }

      it { expect(response).to have_http_status :not_found }
    end
  end
end
