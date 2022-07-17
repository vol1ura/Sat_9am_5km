RSpec.describe '/admin/users', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /admin/users' do
    it 'renders a successful response' do
      create_list :user, 3
      get admin_users_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/users/1' do
    it 'renders a successful response' do
      user = create :user
      get admin_user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/users/batch_action' do
    before do
      user.admin!
      Bullet.unused_eager_loading_enable = false
    end

    after do
      Bullet.unused_eager_loading_enable = true
    end

    let(:valid_attributes) do
      { batch_action: :change_roles, batch_action_inputs: { role: 'uploader' }.to_json, collection_selection: [user.id] }
    end

    it 'renders a successful response' do
      post batch_action_admin_users_url, params: valid_attributes
      expect(response).to redirect_to admin_users_path
    end

    it 'change user role' do
      post batch_action_admin_users_url, params: valid_attributes
      expect(user.reload.role).to eq 'uploader'
    end
  end
end
