# frozen_string_literal: true

RSpec.describe '/api/parkzhrun/athletes' do
  describe 'PUT /api/parkzhrun/athlete' do
    let(:parkzhrun_code) { Faker::Number.number(digits: 5) + Athlete::PARKZHRUN_BORDER }
    let(:athlete_attributes) do
      {
        athlete: {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          gender: %w[male female].sample,
          parkrun_id: Faker::Number.number(digits: 7),
          parkzhrun_id: parkzhrun_code,
        },
      }
    end

    context 'when header api key is invalid' do
      it 'returns unauthorized response' do
        patch(
          api_parkzhrun_athlete_url(parkzhrun_code),
          params: athlete_attributes,
          headers: { 'Authorization' => Faker::Crypto.sha256 },
          as: :json,
        )
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with valid header api key' do
      let!(:athlete) { create(:athlete, parkzhrun_code: parkzhrun_code, male: nil) }
      let(:valid_headers) do
        { 'Authorization' => Rails.application.credentials.parkzhrun_api_key }
      end

      it 'renders successful response' do
        patch api_parkzhrun_athlete_url(parkzhrun_code), params: athlete_attributes, headers: valid_headers, as: :json
        expect(response).to be_successful
        athlete.reload
        expect(athlete.male).to eq(athlete_attributes.dig(:athlete, :gender) == 'male')
        expect(athlete.name).to eq(
          "#{athlete_attributes.dig(:athlete, :first_name)} #{athlete_attributes.dig(:athlete, :last_name).upcase}",
        )
      end

      it 'renders error with invalid five verst code' do
        patch(
          api_parkzhrun_athlete_url(parkzhrun_code),
          params: athlete_attributes.deep_merge(athlete: { five_verst_id: 1 }),
          headers: valid_headers,
          as: :json,
        )
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'renders not found for invalid id' do
        patch api_parkzhrun_athlete_url(1), params: athlete_attributes, headers: valid_headers, as: :json
        expect(response).to have_http_status :not_found
      end
    end
  end
end
