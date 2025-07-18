# frozen_string_literal: true

RSpec.describe Telegram::Notification::User::Message do
  subject(:service) { described_class.new(user, message_text) }

  let(:user) { create(:user) }
  let(:message_text) { 'Hello, user!' }

  before do
    allow(Telegram::Bot).to receive(:call)
    service.call
  end

  describe '#call' do
    it 'calls telegram bot service' do
      expect(Telegram::Bot).to have_received(:call).with(
        'sendMessage',
        hash_including(text: message_text),
      )
    end
  end
end
