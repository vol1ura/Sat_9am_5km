# frozen_string_literal: true

RSpec.describe Notification::User::Message do
  subject(:service) { described_class.new(user, message_text) }

  let(:user) { create(:user) }
  let(:message_text) { 'Hello, user!' }

  before { allow(Telegram::Bot).to receive(:call) }

  describe '#call' do
    it 'calls telegram bot service' do
      service.call

      expect(Telegram::Bot).to have_received(:call).with(
        'sendMessage',
        hash_including(text: message_text),
      )
    end

    context 'when user has email' do
      let(:user) { create(:user, :with_email) }
      let(:html) { '<p>Hello, user!</p>' }
      let(:delivery) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

      before do
        allow(Notification::MarkdownConverter).to receive(:to_html).with(message_text).and_return(html)
        allow(UserNotificationMailer).to receive(:notify).with(user, html).and_return(delivery)
      end

      it 'sends message by email' do
        service.call

        expect(delivery).to have_received(:deliver_now)
        expect(Telegram::Bot).not_to have_received(:call)
      end
    end
  end
end
