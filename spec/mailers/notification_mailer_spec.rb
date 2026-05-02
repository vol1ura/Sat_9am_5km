# frozen_string_literal: true

RSpec.describe NotificationMailer do
  describe '#feedback' do
    let(:mail) { described_class.with(message: 'test message', user_id: 1, user_contact: user_contact).feedback }
    let(:user_contact) { nil }

    it 'renders the mail' do
      expect(mail.subject).to eq('Новый отзыв на сайте С95')
      expect(mail.body).to match('User: http://example.com/admin/users/1').and match('test message')
      expect(mail.to).to eq(described_class::RECIPIENTS)
    end

    context 'with user contact' do
      let(:user_contact) { 'user@example.com' }

      it 'includes contact in the body' do
        expect(mail.body).to match('Contact: user@example.com').and match('test message')
      end
    end
  end

  describe '#parkzhrun_error' do
    let(:mail) { described_class.parkzhrun_error }

    it 'renders the mail' do
      expect(mail.subject).to eq('Ошибка! Не удалось создать забег ПаркЖрун')
      expect(mail.to).to eq(described_class::RECIPIENTS)
      expect(mail.body.encoded).to match('произошла ошибка')
    end
  end
end
