# frozen_string_literal: true

RSpec.describe '/events' do
  let!(:event) { create(:event) }

  describe 'GET /' do
    context 'without :all in params' do
      it 'makes successful request' do
        get events_url
        expect(response).to be_successful
      end
    end
  end

  describe 'GET /events/:code_name' do
    it 'renders a successful response' do
      get event_url(code_name: event.code_name)
      expect(response).to be_successful
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
    it 'returns turbo stream with matched clubs within current TLD' do
      msk_event = create(:event, name: 'Bitza')
      get search_events_url(q: 'bitz'), headers: { 'Host' => 'test.ru', 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to be_successful
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(response.body).to include(msk_event.name)
      expect(response.body).not_to include(event.name)
    end
  end
end
