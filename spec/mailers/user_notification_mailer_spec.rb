# frozen_string_literal: true

RSpec.describe UserNotificationMailer do
  describe '#notify' do
    let(:user) { build_stubbed(:user, :with_email) }
    let(:html_body) { '<strong>Привет!</strong> Не пропусти субботний забег.' }
    let(:mail) { described_class.notify(user, html_body) }

    before { allow(described_class).to receive(:sleep) }

    it 'renders the mail' do
      expect(mail.subject).to eq('Загляните в письмо! Внутри информация о вашей субботе')
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to include(html_body).and include(described_class::UNSUBSCRIBE_URL)
      expect(mail['List-Unsubscribe'].value).to eq("<#{described_class::UNSUBSCRIBE_URL}>")
    end
  end
end
