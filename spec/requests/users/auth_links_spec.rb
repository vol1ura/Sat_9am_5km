# frozen_string_literal: true

RSpec.describe '/auth_links' do
  describe 'GET /:token' do
    let!(:user) { create(:user, auth_token: 'valid_token', auth_token_expires_at: 1.minute.from_now) }
    let(:auth_token) { instance_double(Users::AuthToken) }

    context 'with valid auth token' do
      it 'signs in the user' do
        get auth_link_url(token: 'valid_token')
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('views.greeting', name: user.first_name))
      end
    end

    context 'with invalid auth token' do
      it 'redirects to sign in page with alert' do
        get auth_link_url(token: 'invalid_token')
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq(I18n.t('views.auth_link_invalid'))
      end
    end
  end
end
