RSpec.describe '/admin/dashboard', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /admin' do
    it 'renders a successful response' do
      create_list :activity, 3
      get admin_dashboard_url
      expect(response).to be_successful
    end
  end
end
