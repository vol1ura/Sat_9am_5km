# frozen_string_literal: true

RSpec.describe '/athletes' do
  describe 'GET /athletes' do
    before { create_list(:athlete, 3) }

    context 'when athletes have same name' do
      before do
        create(:athlete, name: 'SOME Test')
        create(:athlete, name: 'Some Other')

        get athletes_url(q: 'Some')
      end

      it 'renders a successful response for name search' do
        expect(response).to be_successful
      end
    end

    context 'with single search result' do
      let!(:athlete) { create(:athlete, parkrun_code: 111_111) }

      it 'renders a successful response for ID search' do
        get athletes_url(q: 111_111)
        expect(response).to redirect_to(athlete_url(athlete))
      end
    end

    it 'renders a successful response for blank search' do
      get athletes_url(q: ' ')
      expect(response).to be_successful
    end
  end

  describe 'GET /athletes/1' do
    it 'renders a successful response' do
      athlete = create(:athlete)
      create_list(:result, 3, athlete:)
      get athlete_url(athlete)
      expect(response).to be_successful
    end
  end

  describe 'GET /athletes/:code/best_result' do
    let(:athlete) { create(:athlete) }

    let!(:old_result) do
      create(
        :result,
        athlete: athlete,
        total_time: 17 * 60,
        activity_params: { date: Date.new(2022, 1, 1) },
      )
    end

    let!(:recent_result) do
      create(
        :result,
        athlete: athlete,
        total_time: 18 * 60,
        activity_params: { date: Date.new(2023, 6, 1) },
      )
    end

    before do
      create(
        :result,
        athlete: athlete,
        total_time: 20 * 60,
        activity_params: { date: Date.new(2023, 1, 1) },
      )

      get "/athletes/#{athlete.parkrun_code}/best_result", params:
    end

    context 'with valid params' do
      let(:params) { { since_date: '2023-01-01' } }
      let(:expected_result) do
        {
          'id' => athlete.id,
          'name' => athlete.name,
          'gender' => 'male',
          'best_result' => {
            'date' => recent_result.date.iso8601,
            'position' => recent_result.position,
            'total_time' => 18 * 60,
          },
        }
      end

      it 'returns the best result since given date in JSON' do
        expect(response).to be_successful
        expect(response.parsed_body['athlete']).to eq(expected_result)
      end
    end

    context 'without since_date' do
      let(:params) { {} }
      let(:expected_result) do
        {
          'id' => athlete.id,
          'name' => athlete.name,
          'gender' => 'male',
          'best_result' => {
            'date' => old_result.date.iso8601,
            'position' => old_result.position,
            'total_time' => 17 * 60,
          },
        }
      end

      it 'returns the best result since the beginning in JSON' do
        expect(response).to be_successful
        expect(response.parsed_body['athlete']).to eq(expected_result)
      end
    end

    context 'with invalid since_date' do
      let(:params) { { since_date: 'invalid-date' } }

      it 'returns an error with unprocessable_content status' do
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['error']).to be_present
      end
    end
  end
end
