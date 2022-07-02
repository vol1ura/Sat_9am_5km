RSpec.describe '/admin/activities', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :activity, 3
      get admin_activities_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      activity = create :activity
      get admin_activity_url(activity)
      expect(response).to be_successful
    end
  end
end
