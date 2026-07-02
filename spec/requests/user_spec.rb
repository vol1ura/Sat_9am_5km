# frozen_string_literal: true

RSpec.describe '/user' do
  let(:user) { create(:user, :with_athlete, with_avatar: true, phone: '79991234567') }

  describe 'GET /user/sign_up' do
    it 'renders successful response' do
      get new_user_registration_url
      expect(response).to be_successful
    end
  end

  context 'with authenticated user' do
    before do
      sign_in user
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
              image: Rack::Test::UploadedFile.new(File.open('spec/fixtures/files/default.png'), 'image/png'),
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

      it 'queues email confirmation when email is changed' do
        new_email = Faker::Internet.email
        expect do
          patch user_url, params: { user: { first_name: user.first_name, last_name: user.last_name, email: new_email } }
        end.to change { user.reload.unconfirmed_email }.to(new_email)
        expect(response).to redirect_to user_path
      end
    end
  end

  context 'when unauthenticated user' do
    describe 'POST /user/login' do
      let(:user) { create(:user, :with_email) }

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
  end
end
