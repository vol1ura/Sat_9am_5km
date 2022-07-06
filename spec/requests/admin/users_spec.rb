RSpec.describe '/admin/users', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :user, 3
      get admin_users_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      user = create :user
      get admin_user_url(user)
      expect(response).to be_successful
    end
  end
end
