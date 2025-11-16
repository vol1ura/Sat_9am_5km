# frozen_string_literal: true

RSpec.describe '/admin/users' do
  let(:user) { create(:user) }

  before do
    user.admin!
    sign_in user, scope: :user
  end

  describe 'GET /admin/users' do
    it 'renders a successful response' do
      create_list(:user, 3)
      get admin_users_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/users/1' do
    it 'renders a successful response' do
      get admin_user_url(user)
      expect(response).to be_successful
    end
  end

  describe 'PATCH /admin/users/1/edit' do
    it 'renders form without role field' do
      get edit_admin_user_url(user)
      expect(response).to be_successful
      expect(response.body).not_to include 'user[role]'
    end

    it 'renders form with role field for super admin' do
      user.super_admin!
      get edit_admin_user_url(user)
      expect(response).to be_successful
      expect(response.body).to include 'user[role]'
    end

    context 'when user is not admin' do
      it 'not contains user role field' do
        user.update!(role: nil)
        get edit_admin_user_url(user)
        expect(response.body).not_to include 'user[role]'
      end
    end
  end

  describe 'PATCH /admin/users/1' do
    let(:valid_attributes) do
      {
        user: {
          first_name: Faker::Name.first_name,
          password: user.password,
          password_confirmation: user.password,
        },
      }
    end

    it "updates user's data" do
      patch admin_user_url(user), params: valid_attributes
      expect(user.reload.first_name).to eq valid_attributes.dig(:user, :first_name)
    end
  end

  describe 'POST /admin/users/batch_action' do
    before do
      Bullet.unused_eager_loading_enable = false
    end

    after do
      Bullet.unused_eager_loading_enable = true
    end

    let(:valid_attributes) do
      { batch_action: :change_roles, batch_action_inputs: { role: nil }.to_json, collection_selection: [user.id] }
    end

    it 'renders a successful response' do
      post batch_action_admin_users_url, params: valid_attributes
      expect(response).to redirect_to admin_users_path
    end

    it 'change user role' do
      post batch_action_admin_users_url, params: valid_attributes
      expect(user.reload.role).to be_nil
    end
  end
end
