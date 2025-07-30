# frozen_string_literal: true

RSpec.describe '/api/mobile/athletes' do
  describe 'GET /:code/info' do
    let(:athlete) { create(:athlete) }
    let(:expected_result) do
      {
        'name' => athlete.name,
        'male' => athlete.male,
        'home_event' => nil,
        'volunteering' => include(
          'scheduled' => [include('event_name', 'date', 'role', 'town')],
          'stats' => { 'general' => nil, 'history' => {} },
        ),
      }
    end

    before do
      create(:volunteer, athlete: athlete, activity_params: { date: Date.tomorrow, published: false })
      get api_mobile_url(athlete.code)
    end

    it 'returns the athlete history stats' do
      expect(response).to be_successful
      expect(response.parsed_body).to include(expected_result)
    end
  end
end
