# frozen_string_literal: true

RSpec.describe '/api/challenger/athletes/latest_runs' do
  let(:api_key) { 'challenger-test-key' }
  let(:headers) { { 'Authorization' => "Bearer #{api_key}" } }
  let(:path) { latest_runs_api_challenger_athletes_path }

  before do
    allow(Rails.application.credentials).to receive(:dig).and_call_original
    allow(Rails.application.credentials).to receive(:dig).with(:challenger, :api_key).and_return(api_key)
  end

  describe 'GET /api/challenger/athletes/latest_runs' do
    it 'rejects a missing key' do
      get path, params: { ids: [1] }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'fails closed when the api key is blank' do
      allow(Rails.application.credentials).to receive(:dig).with(:challenger, :api_key).and_return('')
      get path, params: { ids: [1] }, headers: headers

      expect(response).to have_http_status(:service_unavailable)
    end

    it 'returns an empty list when ids are empty' do
      get(path, headers:)

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq('runs' => [])
    end

    it 'rejects more than 100 ids' do
      get path, params: { ids: (1..101).to_a }, headers: headers

      expect(response).to have_http_status(:unprocessable_content)
    end

    context 'when the athlete has several runs' do
      let(:event) { create(:event, name: 'ЗИЛ', code_name: 'zil') }
      let(:athlete) { create(:athlete) }
      let!(:latest) do
        create(:result, athlete: athlete, total_time: 1530, activity_params: { date: Date.new(2026, 11, 21), event: event })
      end
      let(:expected_run) do
        {
          'athlete_id' => athlete.id,
          'activity_id' => latest.activity_id,
          'date' => '2026-11-21',
          'total_time' => '25:30',
          'event' => { 'id' => event.id, 'code_name' => 'zil', 'name' => 'ЗИЛ' },
        }
      end

      before do
        create(:result, athlete: athlete, total_time: 1500, activity_params: { date: Date.new(2026, 11, 14), event: event })
        create(
          :result,
          athlete: athlete,
          total_time: 1400,
          activity_params: { date: Date.new(2026, 11, 22), event: event, published: false },
        )
      end

      it 'returns the latest published run' do
        other = create(:athlete)
        get path, params: { ids: [athlete.id, other.id, 0] }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.fetch('runs')).to eq([expected_run])
      end
    end

    it 'does not insert rows' do
      athlete = create(:athlete)

      expect { get path, params: { ids: [athlete.id] }, headers: headers }.not_to change(Result, :count)
    end
  end
end
