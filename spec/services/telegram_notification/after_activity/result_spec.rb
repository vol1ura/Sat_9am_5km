# frozen_string_literal: true

RSpec.describe TelegramNotification::AfterActivity::Result, type: :service do
  let(:result) { create(:result, athlete: create(:athlete, user: create(:user))) }
  let(:bot_token) { '123456:aaabbb' }
  let!(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/sendMessage}) }

  before { stub_const('TelegramNotification::Bot::TOKEN', bot_token) }

  context 'when request to telegram successful' do
    it 'informs athlete' do
      described_class.call(result)
      expect(request).to have_been_requested
      expect(result.reload).to be_informed
    end
  end

  context 'when request to telegram fails' do
    before { request.to_raise(StandardError) }

    it 'not informs athlete' do
      described_class.call(result)
      expect(request).to have_been_requested
      expect(result.reload).not_to be_informed
    end
  end
end
