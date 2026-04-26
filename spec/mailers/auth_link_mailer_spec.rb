# frozen_string_literal: true

RSpec.describe AuthLinkMailer do
  describe '#login_link' do
    let(:user) do
      build_stubbed(
        :user,
        :with_email,
        auth_token: 'a' * 32,
        auth_token_expires_at: Users::AuthToken::TTL.from_now,
      )
    end
    let(:mail) { described_class.login_link(user) }

    it 'renders the mail' do
      expect(mail.subject).to eq('Ссылка для входа на сайт С95')
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded)
        .to include(user.first_name)
        .and include("/auth_links/#{user.auth_token}")
        .and include((Users::AuthToken::TTL / 1.minute).to_s)
    end

    context 'when the auth token is invalid' do
      let(:user) { build_stubbed(:user, :with_email, auth_token: nil, auth_token_expires_at: nil) }

      it 'does not deliver the mail' do
        expect(mail.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end
end
