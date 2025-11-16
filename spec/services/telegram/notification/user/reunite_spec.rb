# frozen_string_literal: true

RSpec.describe Telegram::Notification::User::Reunite, type: :service do
  let(:user) { create(:user, athlete:) }
  let(:athlete) { create(:athlete) }
  let(:bot_token) { '123456:aaabbb' }
  let!(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/sendMessage}) }

  before do
    stub_const('Telegram::Bot::TOKEN', bot_token)
    described_class.call(user)
  end

  it 'informs athlete' do
    expect(request).to have_been_requested
  end
end
