# frozen_string_literal: true

# rubocop:disable RSpec/ExampleLength
RSpec.describe '/api/mobile/activities/upcoming' do
  let(:user) { create(:user, :admin, :with_athlete) }
  let(:activity) { create(:activity, published: false, date: Date.tomorrow) }
  let(:headers) do
    _session, token = MobileSession.issue_for!(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  before do
    create(:volunteer, athlete: user.athlete, activity: activity, role: :director)
    create(:result, activity:)
  end

  it 'returns the nearest activity with director capabilities' do
    get '/api/mobile/activities/upcoming', headers: headers, as: :json

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to include(
      'id' => activity.id,
      'number' => activity.number,
      'capabilities' => include(
        'manage_results' => true,
        'manage_volunteers' => true,
        'toggle_mode' => true,
        'publish' => true,
      ),
    )
    expect(response.parsed_body['results']).not_to be_empty
  end

  it 'does not expose the activity token before the event date' do
    activity.update!(token: SecureRandom.uuid)

    get '/api/mobile/activities/upcoming', headers: headers, as: :json

    expect(response.parsed_body['automatic']).to be true
    expect(response.parsed_body['activity_token']).to be_nil
  end

  it 'returns all volunteer roles translated into the requested locale' do
    get '/api/mobile/activities/upcoming', params: { locale: :en }, headers: headers, as: :json

    expect(response.parsed_body['volunteer_roles']).to include(
      { 'value' => 'director', 'label' => 'Director' },
    )
    expect(response.parsed_body['volunteer_roles'].pluck('value')).to eq(Volunteer.roles.keys)
  end

  it 'exposes the activity token to a director on the event date' do
    activity.update!(date: Date.current, token: SecureRandom.uuid)

    get '/api/mobile/activities/upcoming', headers: headers, as: :json

    expect(response.parsed_body['activity_token']).to eq activity.token
  end

  it 'does not expose results or management to a non-director volunteer' do
    activity.volunteers.find_by(athlete: user.athlete).update!(role: :marshal)

    get '/api/mobile/activities/upcoming', headers: headers, as: :json

    expect(response.parsed_body.dig('capabilities', 'manage_results')).to be false
    expect(response.parsed_body['results']).to eq []
  end

  it 'rejects a stale revision when changing mode' do
    patch "/api/mobile/activities/#{activity.id}/mode",
          params: { automatic: true, revision: 1.day.ago.iso8601(6) },
          headers: headers,
          as: :json

    expect(response).to have_http_status(:conflict)
  end

  it 'allows access to an unpublished activity exactly two weeks old' do
    activity.update!(date: 2.weeks.ago.to_date)

    get "/api/mobile/activities/#{activity.id}", headers: headers, as: :json

    expect(response).to have_http_status(:ok)
  end

  it 'does not allow access to an activity older than two weeks' do
    activity.update!(date: 2.weeks.ago.to_date - 1.day)

    get "/api/mobile/activities/#{activity.id}", headers: headers, as: :json

    expect(response).to have_http_status(:not_found)
  end

  it 'does not allow access to a published activity' do
    activity.update!(published: true)

    get "/api/mobile/activities/#{activity.id}", headers: headers, as: :json

    expect(response).to have_http_status(:not_found)
  end
end
# rubocop:enable RSpec/ExampleLength
