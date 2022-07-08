RSpec.describe '/events', type: :request do
  describe 'GET /show' do
    it 'renders a successful response' do
      event = create :event
      get event_url(code_name: event.code_name)
      expect(response).to be_successful
    end
  end
end
