# frozen_string_literal: true

# rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
RSpec.describe '/api/mobile/auth' do
  let(:athlete) { create(:athlete, :with_user) }

  it 'identifies an athlete and exchanges a one-time code for a session' do
    post '/api/mobile/auth/identify', params: { athlete_code: "A#{athlete.code}", country: 'ru' }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include('status' => 'found', 'athlete_code' => athlete.code)

    pairing_code = MobilePairingCode.generate_for!(athlete.user)
    post '/api/mobile/auth/session',
         params: { athlete_code: athlete.code, pairing_code: pairing_code, device_name: 'RSpec' },
         as: :json

    expect(response).to have_http_status(:created)
    token = response.parsed_body.fetch('token')

    get '/api/mobile/me', headers: { 'Authorization' => "Bearer #{token}" }, as: :json
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.dig('athlete', 'code')).to eq athlete.code

    delete '/api/mobile/auth/session', headers: { 'Authorization' => "Bearer #{token}" }, as: :json
    expect(response).to have_http_status(:no_content)

    get '/api/mobile/me', headers: { 'Authorization' => "Bearer #{token}" }, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it 'returns registration states without issuing a session' do
    unlinked = create(:athlete)
    post '/api/mobile/auth/identify', params: { athlete_code: unlinked.code, country: 'rs' }, as: :json

    expect(response.parsed_body).to include(
      'status' => 'account_unlinked',
      'registration_url' => 'https://s95.rs/user',
    )
  end
end
# rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
