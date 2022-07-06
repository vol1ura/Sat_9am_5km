RSpec.describe '/admin/volunteers', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :volunteer, 3
      get admin_volunteers_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      volunteer = create :volunteer
      get admin_volunteer_url(volunteer)
      expect(response).to be_successful
    end
  end
end
