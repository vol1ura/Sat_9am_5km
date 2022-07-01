RSpec.describe '/events', type: :request do
  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :event, 3
      get events_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      event = create :event
      get event_url(code_name: event.code_name)
      expect(response).to be_successful
    end
  end
end
