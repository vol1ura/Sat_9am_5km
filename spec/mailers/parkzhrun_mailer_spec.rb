# frozen_string_literal: true

RSpec.describe ParkzhrunMailer do
  let(:recepients) { %w[to1@example.org to2@example.org] }

  before { stub_const('ParkzhrunMailer::RECIPIENTS', recepients) }

  describe '#success' do
    let(:mail) { described_class.success }

    it 'renders the headers' do
      expect(mail.subject).to eq('Забег ПаркЖрун создан')
      expect(mail.to).to eq(recepients)
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('успешно создан')
    end
  end

  describe '#error' do
    let(:mail) { described_class.error }

    it 'renders the headers' do
      expect(mail.subject).to eq('Ошибка! Не удалось создать забег ПаркЖрун')
      expect(mail.to).to eq(recepients)
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('произошла ошибка')
    end
  end
end
