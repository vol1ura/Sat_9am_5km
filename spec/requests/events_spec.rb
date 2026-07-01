# frozen_string_literal: true

RSpec.describe '/events' do
  let!(:event) do
    event = create(:event)
    event.summer_image.attach(
      io: File.open('spec/fixtures/files/default.png'),
      filename: 'summer.png',
    )
    event.winter_image.attach(
      io: File.open('spec/fixtures/files/default.png'),
      filename: 'winter.png',
    )
    event
  end

  describe 'GET /' do
    it 'makes successful request in summer' do
      travel_to Time.zone.local(2025, 4, 1) do
        get events_url
        expect(response).to be_successful
      end
    end

    it 'makes successful request in winter' do
      travel_to Time.zone.local(2025, 11, 1) do
        get events_url
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /events/:code_name' do
    before do
      if Badge.instance_variable_defined?(:@participating_thresholds)
        Badge.remove_instance_variable(:@participating_thresholds)
      end
      create(:participating_badge, type: 'result')
      create(:participating_badge, type: 'volunteer')
    end

    it 'renders a successful response' do
      get event_url(code_name: event.code_name)
      expect(response).to be_successful
    end
  end

  describe 'GET /events/:code_name.json' do
    let(:activity) { create(:activity, event: event, date: '2026-06-20') }
    let!(:result) { create(:result, activity:) }

    def event_json
      get event_url(code_name: event.code_name, format: :json)
      response.parsed_body
    end

    it 'returns the latest protocol change time across published activities' do
      expect(event_json['updated_at']).to eq(event.activities.published.maximum(:updated_at).iso8601)
    end

    it 'exposes date, updated_at and url for each activity' do
      json_activity = event_json.dig('activities', 0)
      expect(json_activity['date']).to eq('2026-06-20')
      expect(json_activity['updated_at']).to eq(activity.reload.updated_at.iso8601)
    end

    it 'bumps updated_at when a protocol row changes' do
      before = event_json['updated_at']
      travel_to(1.minute.from_now) { result.update!(position: 99) }
      expect(event_json['updated_at']).to be > before
    end

    it 'bumps updated_at when a protocol row is added' do
      before = event_json['updated_at']
      travel_to(1.minute.from_now) { create(:result, activity:) }
      expect(event_json['updated_at']).to be > before
    end

    it 'bumps updated_at when a protocol row is removed' do
      before = event_json['updated_at']
      travel_to(1.minute.from_now) { result.destroy! }
      expect(event_json['updated_at']).to be > before
    end

    it 'does NOT bump updated_at when an athlete only edits their name' do
      before = event_json['updated_at']
      travel_to(1.minute.from_now) { result.athlete.update!(name: 'ИВАН ПЕТРОВ') }
      expect(event_json['updated_at']).to eq(before)
    end

    context 'with updated_since filter' do
      before do
        travel_to(2.days.ago) { create(:result, activity: create(:activity, event: event, date: '2026-06-01')) }
      end

      it 'returns only activities updated after the given time' do
        get event_url(code_name: event.code_name, format: :json, updated_since: 1.day.ago.iso8601)

        dates = response.parsed_body['activities'].pluck('date')
        expect(dates).to eq(['2026-06-20'])
      end

      it 'returns 422 for an invalid updated_since' do
        get event_url(code_name: event.code_name, format: :json, updated_since: 'not-a-date')

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'GET /events/:code_name/volunteering' do
    it 'renders a successful response' do
      activity = create(:activity, date: Faker::Date.forward(days: 20))
      create_list(:volunteer, 3, activity:)
      get volunteering_event_url(code_name: event.code_name)
      expect(response).to be_successful
    end
  end

  describe 'GET /search' do
    it 'returns turbo stream with matched clubs within current top level domain' do
      msk_event = create(:event, name: 'Bitza')
      get search_events_url(q: 'bitz'), headers: { 'Host' => 'test.ru', 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to be_successful
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include(msk_event.name)
      expect(response.body).not_to include(event.name)
    end
  end
end
