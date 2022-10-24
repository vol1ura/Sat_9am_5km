RSpec.describe '/events' do
  let(:event) { create(:event) }

  describe 'GET /show' do
    it 'renders a successful response' do
      get event_url(code_name: event.code_name)
      expect(response).to be_successful
    end
  end

  describe 'GET /volunteering' do
    it 'renders a successful response' do
      activity = create(:activity, date: Faker::Date.forward(days: 20))
      create_list(:volunteer, 3, activity: activity)
      get volunteering_event_url(code_name: event.code_name)
      expect(response).to be_successful
    end
  end
end
