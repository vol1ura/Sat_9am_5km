# frozen_string_literal: true

RSpec.describe '/user/confirmation' do
  describe 'GET /user/confirmation?confirmation_token=abcdef' do
    let(:user) { create(:user, :with_email, :with_athlete) }
    let(:raw_token) do
      raw, hashed = Devise.token_generator.generate(User, :confirmation_token)
      user.update!(confirmation_token: hashed, confirmation_sent_at: Time.current, confirmed_at: nil)
      raw
    end

    context 'with valid confirmation token' do
      it 'confirms the user, signs them in and redirects to user settings page', :aggregate_failures do
        get user_confirmation_path(confirmation_token: raw_token)

        expect(response).to redirect_to(user_path)
        expect(user.reload.confirmed?).to be true

        get user_path
        expect(response).to be_successful
      end
    end

    context 'with invalid confirmation token' do
      it 'does not sign in and re-renders the form', :aggregate_failures do
        get user_confirmation_path(confirmation_token: 'invalid-token')

        expect(response).to have_http_status(:unprocessable_content)
        get user_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'GET /user/confirmation/new' do
    it 'pre-fills the email input when user[email] is passed in query string' do
      get new_user_confirmation_path(user: { email: 'test@test.ru' })

      expect(response).to be_successful
      doc = Nokogiri::HTML(response.body)
      expect(doc.at_css('input[name="user[email]"]')['value']).to eq 'test@test.ru'
    end

    context 'when user is signed in' do
      let(:user) { create(:user, :with_email, :with_athlete) }

      before { sign_in user }

      it 'shows a sign-out warning on the form' do
        get new_user_confirmation_path

        expect(response.body).to include(I18n.t('devise.confirmations.new.sign_out_warning'))
      end
    end
  end

  describe 'POST /user/confirmation' do
    let(:user) { create(:user, :with_email, :with_athlete) }

    before { user.update!(unconfirmed_email: 'new@example.com') }

    context 'when user is signed in' do
      before { sign_in user }

      it 'signs the user out, enqueues the confirmation email and redirects to sign in', :aggregate_failures do
        expect do
          post user_confirmation_path, params: { user: { email: 'new@example.com' } }
        end.to have_enqueued_mail(Devise::Mailer, :confirmation_instructions).with(user, anything, anything)

        expect(response).to redirect_to(new_user_session_path)

        get root_path
        expect(flash[:alert]).to be_blank
        expect(controller.user_signed_in?).to be false
      end
    end
  end
end
