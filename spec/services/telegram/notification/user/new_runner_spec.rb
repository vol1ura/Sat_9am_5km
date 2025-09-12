# frozen_string_literal: true

RSpec.describe Telegram::Notification::User::NewRunner, type: :service do
  let(:user) { create(:user) }
  let(:bot_token) { '123456:aaabbb' }
  let!(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/sendMessage}) }

  before do
    create(:result, athlete: create(:athlete, user:))
    stub_const('Telegram::Bot::TOKEN', bot_token)
  end

  context 'when request to telegram successful' do
    it 'informs athlete' do
      described_class.call(user)
      expect(request).to have_been_requested
    end
  end

  context 'when request to telegram fails' do
    before { request.to_raise(StandardError) }

    it 'not informs athlete' do
      described_class.call(user)
      expect(request).to have_been_requested.times(3)
    end
  end
end
