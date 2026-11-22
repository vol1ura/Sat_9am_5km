# frozen_string_literal: true

RSpec.describe '/api/mobile/athletes' do
  describe 'GET /search' do
    let!(:athlete) { create(:athlete, name: 'Some Volunteer') }

    it 'searches by name through AthletesController#index' do
      get '/api/mobile/athletes/search', params: { q: 'Some' }, as: :json

      expect(response).to be_successful
      expect(response.parsed_body['athletes']).to include(
        include('id' => athlete.id, 'code' => athlete.code, 'name' => athlete.name),
      )
    end
  end
end
