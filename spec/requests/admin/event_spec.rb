RSpec.describe '/admin/event', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :event, 3
      get admin_events_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      event = create :event
      get admin_event_url(event)
      expect(response).to be_successful
    end
  end
end
