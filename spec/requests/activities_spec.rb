RSpec.describe '/activities' do
  describe 'GET /index' do
    it 'renders a successful response' do
      create_list(:activity, 3)
      get activities_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      activity = create(:activity)
      get activity_url(activity)
      expect(response).to be_successful
    end
  end
end
