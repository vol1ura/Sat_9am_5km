# frozen_string_literal: true

RSpec.describe UserNotificationMailer do
  describe '#notify' do
    let(:country) { countries(:ru) }
    let(:user) { build_stubbed(:user, :with_email, country:) }
    let(:html_body) { '<strong>Привет!</strong> Не пропусти субботний забег.' }
    let(:mail) { described_class.notify(user, html_body) }
    let(:unsubscribe_url) { "https://#{country.host}/user" }
    let(:locale) { country.locale }
    let(:unsubscribe_html) do
      I18n.t('user_notification_mailer.notify.unsubscribe_html', url: unsubscribe_url, locale: locale)
    end

    before { allow(described_class).to receive(:sleep) }

    it 'renders the mail' do
      expect(mail.subject).to eq(I18n.t('user_notification_mailer.notify.subject', locale:))
      expect(mail.to).to eq([ENV.fetch('ADMIN_EMAIL')])
      expect(mail.body.encoded).to include(html_body).and include(unsubscribe_url).and include(unsubscribe_html)
      expect(mail['List-Unsubscribe'].value).to eq("<#{unsubscribe_url}>")
    end

    context 'when user country is Serbia' do
      let(:country) { Country.new(code: 'rs') }

      it 'translates subject and unsubscribe footer' do
        expect(mail.subject).to eq(I18n.t('user_notification_mailer.notify.subject', locale: :sr))
        expect(mail.body.encoded).to include(unsubscribe_url).and include(unsubscribe_html)
      end
    end
  end
end
