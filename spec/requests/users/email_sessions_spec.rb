# frozen_string_literal: true

RSpec.describe '/email_sessions' do
  let(:user) { create(:user, :with_email) }

  describe 'POST /email_sessions (create)' do
    context 'with a confirmed user' do
      it 'sends login link and redirects to sign in' do
        expect do
          post email_sessions_url, params: { email: user.email }
        end.to have_enqueued_mail(AuthLinkMailer, :login_link)

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:notice]).to eq(I18n.t('users.email_sessions.create.link_sent'))
      end
    end

    context 'with an unknown email' do
      it 'redirects to registration without sending email' do
        email = 'unknown@example.com'

        expect do
          post email_sessions_url, params: { email: }
        end.not_to have_enqueued_mail(AuthLinkMailer, :login_link)

        expect(response).to redirect_to(new_user_registration_path(user: { email: }))
        expect(flash[:alert]).to eq(I18n.t('users.email_sessions.create.not_registered'))
      end
    end

    context 'with an unconfirmed user' do
      it 'redirects to confirmation resend without sending email' do
        unconfirmed = create(:user, :with_email)
        unconfirmed.update!(confirmed_at: nil)

        expect do
          post email_sessions_url, params: { email: unconfirmed.email }
        end.not_to have_enqueued_mail(AuthLinkMailer, :login_link)

        expect(response).to redirect_to(new_user_confirmation_path(user: { email: unconfirmed.email }))
        expect(flash[:alert]).to eq(I18n.t('users.email_sessions.create.unconfirmed'))
      end
    end
  end
end
