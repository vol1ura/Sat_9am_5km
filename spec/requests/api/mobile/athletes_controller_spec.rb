# spec/controllers/api/mobile/athletes_controller_spec.rb
# frozen_string_literal: true

RSpec.describe '/api/mobile/athletes' do
  describe 'GET /:code/info' do
    let(:athlete) { create(:athlete) }
    let(:bearer_token) { 'valid_token' }

    before do
      stub_const('API::Mobile::ApplicationController::AUTHORIZATION_HEADER', 'Bearer valid_token')
      get api_mobile_url(athlete.code), headers: { Authorization: "Bearer #{bearer_token}" }
    end

    context 'with invalid bearer token' do
      let(:bearer_token) { 'invalid_token' }

      it { expect(response).to have_http_status(:unauthorized) }
    end

    it 'returns the athlete history stats' do
      expect(response).to be_successful
      expect(response.parsed_body).to include(
        'name' => athlete.name,
        'male' => athlete.male,
        'home_event' => nil,
        'volunteering' => include(
          'scheduled' => [],
          'stats' => { 'general' => nil, 'history' => {} },
        ),
      )
    end
  end
end
