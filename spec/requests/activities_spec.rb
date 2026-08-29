# frozen_string_literal: true

RSpec.describe '/activities' do
  describe 'GET /index' do
    it 'renders a successful response' do
      create_list(:activity, 3)
      get activities_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    let(:activity) { create(:activity) }
    let!(:result) { create(:result, activity:) }
    let!(:volunteer) { create(:volunteer, activity:) }
    let(:athlete_fields) { %i[id name parkrun_code gender] }

    it 'renders a successful response' do
      create(:participating_badge)
      get activity_url(activity)

      expect(response).to be_successful
    end

    it 'renders json' do
      get activity_url(activity, format: :json)

      expect(response.parsed_body.dig('results', 0)).to eq(
        'total_time' => result.time_string,
        'position' => result.position,
        'athlete' => result.athlete.as_json(only: athlete_fields),
      )
      expect(response.parsed_body.dig('volunteers', 0)).to eq(
        'role' => volunteer.role,
        'athlete' => volunteer.athlete.as_json(only: athlete_fields),
      )
    end
  end

  describe 'GET /dashboard' do
    it 'renders a successful response' do
      create_list(:activity, 3, date: Date.current)
      get dashboard_activities_url, headers: { host: 'test.ru' }
      expect(response).to be_successful
    end
  end

  describe 'GET /changes' do
    it 'returns activities updated after updated_since, ordered by updated_at, with meta' do
      travel_to(3.days.ago) { create(:activity) }
      first = travel_to(2.hours.ago) { create(:activity) }
      second = travel_to(1.hour.ago) { create(:activity) }

      get changes_activities_url(format: :json, updated_since: 1.day.ago.iso8601), headers: { host: 'test.ru' }

      expect(response.parsed_body['activities'].pluck('id')).to eq([first.id, second.id])
      expect(response.parsed_body['meta']).to include('page' => 1, 'total_pages' => 1, 'total_count' => 2)
    end

    it 'exposes the event summary and json url per activity' do
      activity = create(:activity)

      get changes_activities_url(format: :json), headers: { host: 'test.ru' }

      json_activity = response.parsed_body.dig('activities', 0)
      expect(json_activity['event']).to eq('code_name' => activity.event.code_name)
      expect(json_activity['url']).to end_with("/activities/#{activity.id}.json")
    end

    it 'excludes unpublished activities' do
      create(:activity, published: false)

      get changes_activities_url(format: :json), headers: { host: 'test.ru' }

      expect(response.parsed_body['activities']).to be_empty
    end

    it 'returns 422 for an invalid updated_since' do
      get changes_activities_url(format: :json, updated_since: 'not-a-date'), headers: { host: 'test.ru' }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
