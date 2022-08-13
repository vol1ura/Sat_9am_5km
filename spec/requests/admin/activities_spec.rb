RSpec.describe '/admin/activities', type: :request do
  let(:user) { create(:user) }
  let(:event) { create :event }

  before do
    create :permission, user: user, action: 'read', subject_class: 'Activity', event_id: event.id
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :activity, 3, event: event
      get admin_activities_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      activity = create :activity, published: false, event: event
      get admin_activity_url(activity)
      expect(response).to be_successful
    end
  end
end
