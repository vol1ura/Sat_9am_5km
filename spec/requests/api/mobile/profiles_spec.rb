# frozen_string_literal: true

RSpec.describe '/api/mobile/me' do
  let(:athlete) { create(:athlete, :with_user) }
  let(:headers) do
    _session, token = MobileSession.issue_for!(athlete.user)
    { 'Authorization' => "Bearer #{token}" }
  end
  let(:expected_profile) do
    {
      'code' => athlete.code,
      'name' => athlete.name,
      'gender' => athlete.gender,
      'home_event' => nil,
      'volunteering' => include(
        'scheduled' => [include('event_name', 'date', 'role', 'town')],
        'stats' => { 'general' => nil, 'history' => { 'timer' => [0, 1, 0, 0, 0, 0] } },
      ),
    }
  end

  before do
    create(:volunteer, athlete: athlete, activity_params: { date: 4.months.ago }, role: :timer)
    create(:volunteer, athlete: athlete, activity_params: { date: Date.tomorrow, published: false })
  end

  it 'returns the authenticated athlete profile and volunteering data' do
    get '/api/mobile/me', params: { locale: :en }, headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.fetch('athlete')).to include(expected_profile)
    expect(response.parsed_body.fetch('volunteer_roles')).to include(
      { 'value' => 'timer', 'label' => 'Timer' },
    )
  end
end
