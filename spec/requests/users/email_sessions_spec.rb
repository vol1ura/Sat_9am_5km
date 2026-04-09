# frozen_string_literal: true

RSpec.describe '/email_sessions' do
  let(:user) { create(:user, :with_email) }

  describe 'POST /email_sessions (create)' do
    context 'with an unconfirmed or missing email' do
      it 'redirects without sending email' do
        expect do
          post email_sessions_url, params: { email: 'unknown@example.com' }
        end.not_to have_enqueued_mail(AuthLinkMailer, :login_link)

        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:notice]).to be_present
      end

      it 'does not send email for unconfirmed user' do
        unconfirmed = create(:user, :with_email)
        unconfirmed.update!(confirmed_at: nil)

        expect do
          post email_sessions_url, params: { email: unconfirmed.email }
        end.not_to have_enqueued_mail(AuthLinkMailer, :login_link)

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
