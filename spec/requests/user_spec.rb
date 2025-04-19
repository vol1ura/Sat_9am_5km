# frozen_string_literal: true

RSpec.describe '/user' do
  let(:user) { create(:user, with_avatar: true, phone: '79991234567') }

  describe 'GET /user/sign_up' do
    it 'renders successful response' do
      get new_user_registration_url
      expect(response).to redirect_to 'https://t.me/sat9am5kmbot'
    end
  end

  context 'with authenticated user' do
    before do
      sign_in user, scope: :user
      Bullet.n_plus_one_query_enable = false if defined?(Bullet)
    end

    after do
      Bullet.n_plus_one_query_enable = true if defined?(Bullet)
    end

    describe 'GET /user' do
      before { get user_url }

      it { expect(response).to be_successful }
    end

    describe 'GET /user/edit' do
      before { get edit_user_url }

      it { expect(response).to be_successful }
    end

    describe 'POST /user' do
      it 'updates user attributes' do
        expect { patch user_url, params: { user: { first_name: 'Tester' } } }
          .to change(user, :first_name).to('Tester')

        expect(CompressUserImageJob).not_to have_been_enqueued
        expect(response).to redirect_to user_path
      end

      it 'enqueues job' do
        patch(
          user_url,
          params: {
            user: {
              image: Rack::Test::UploadedFile.new(File.open('spec/fixtures/files/default.png')),
            },
          },
        )

        expect(CompressUserImageJob).to have_been_enqueued
        expect(response).to redirect_to user_path
      end

      it 'does not enqueued job to compress image' do
        patch user_url, params: { delete_image: '1', user: user.attributes.slice('first_name', 'last_name') }
        expect(CompressUserImageJob).not_to have_been_enqueued
        expect(response).to redirect_to user_path
      end

      it 'deletes phone' do
        patch user_url, params: { delete_phone: 'true', user: user.attributes.slice('first_name') }
        expect(user.phone).to be_nil
      end
    end
  end

  context 'when unauthenticated user' do
    describe 'POST /user/login' do
      it 'redirects to root page after successful login' do
        post user_session_url, params: { user: { email: user.email, password: user.password } }
        expect(response).to redirect_to root_path
      end
    end

    describe 'GET /user/login' do
      before { get new_user_session_url }

      it { expect(response).to be_successful }
    end

    describe 'GET /user/password/new' do
      before { get new_user_password_url }

      it { expect(response).to be_successful }
    end

    describe 'GET /user/confirmation/new' do
      before { get new_user_confirmation_url }

      it { expect(response).to be_successful }
    end

    describe 'GET /user/unlock/new' do
      before { get new_user_unlock_url }

      it { expect(response).to be_successful }
    end

    describe 'POST /user/auth/telegram' do
      let(:telegram_id) { 1234567 }
      let(:auth_hash) { OmniAuth::AuthHash.new(uid: telegram_id.to_s) }

      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:telegram] = auth_hash
      end

      it 'redirects to new registration url unregistered user' do
        post user_telegram_omniauth_callback_url
        expect(response).to redirect_to new_user_registration_url
      end

      context 'with registered user' do
        before { create(:user, telegram_id:) }

        it 'returns success' do
          post user_telegram_omniauth_callback_url
          expect(response).to redirect_to root_url
          expect(flash[:notice]).to include 'Telegram'
        end
      end

      context 'with failure' do
        let(:auth_hash) { :invalid_credentials }

        it 'redirects to login path' do
          expect { post user_telegram_omniauth_callback_url }.to output.to_stdout_from_any_process
          expect(response).to redirect_to new_user_session_url
        end
      end
    end
  end
end
