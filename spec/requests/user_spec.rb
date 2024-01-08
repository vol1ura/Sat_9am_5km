# frozen_string_literal: true

RSpec.describe '/user' do
  let(:user) { create(:user) }

  describe 'GET /user/sign_up' do
    it 'renders successful response' do
      get new_user_registration_url
      expect(response).to redirect_to 'https://t.me/sat9am5kmbot'
    end
  end

  describe 'POST /user/login' do
    it 'redirects to root page after successful login' do
      post user_session_url, params: { user: { email: user.email, password: user.password } }
      expect(response).to redirect_to root_path
    end
  end
end
