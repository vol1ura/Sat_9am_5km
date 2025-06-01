# frozen_string_literal: true

RSpec.describe NotificationMailer do
  describe '#feedback' do
    let(:mail) { described_class.with(message: 'test message', user_id: 1).feedback }

    it 'renders the mail' do
      expect(mail.subject).to eq('Новый отзыв на сайте S95')
      expect(mail.body).to match('User ID: 1').and match('test message')
      expect(mail.to).to eq(described_class::RECIPIENTS)
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
