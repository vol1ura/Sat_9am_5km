# frozen_string_literal: true

RSpec.describe Notification::Channel::Email do
  subject(:deliver) { described_class.deliver(user, text:) }

  let(:user) { create(:user, :with_email) }
  let(:text) { 'Notification text' }
  let(:html) { '<p>Notification text</p>' }
  let(:delivery) { instance_double(ActionMailer::MessageDelivery) }

  before do
    allow(Notification::MarkdownConverter).to receive(:to_html).with(text).and_return(html)
    allow(UserNotificationMailer).to receive(:notify).with(user, html).and_return(delivery)
  end

  it 'retries delivery after a network timeout' do
    attempts = 0
    allow(delivery).to receive(:deliver_now) do
      attempts += 1
      raise Net::ReadTimeout if attempts < 3
    end

    deliver

    expect(delivery).to have_received(:deliver_now).exactly(3).times
  end

  it 'raises after three unsuccessful attempts' do
    allow(delivery).to receive(:deliver_now).and_raise(Net::OpenTimeout)

    expect { deliver }.to raise_error(Net::OpenTimeout)
    expect(delivery).to have_received(:deliver_now).exactly(3).times
  end
end
