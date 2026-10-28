# frozen_string_literal: true

RSpec.describe Notification::Newsletter do
  let(:user) { create(:user) }
  let(:bot_token) { '123456:aaabbb' }
  let(:telegram_method) { 'sendMessage' }
  let!(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/#{telegram_method}}) }
  let(:newsletter) { create(:newsletter) }

  before { stub_const('Telegram::Bot::TOKEN', bot_token) }

  shared_examples 'successfully sends newsletter' do
    specify do
      expect { described_class.call newsletter, user }.to change(newsletter, :sent_count).by(1)
      expect(request).to have_been_requested
    end
  end

  it_behaves_like 'successfully sends newsletter'

  context 'with image' do
    let(:telegram_method) { 'sendPhoto' }
    let(:newsletter) { create(:newsletter, picture_link: Faker::Internet.url(host: 'test.com', path: '/pic.png')) }

    it_behaves_like 'successfully sends newsletter'
  end

  context 'when user has email' do
    let(:user) { create(:user, :with_email) }
    let(:html) { '<p>Newsletter body</p>' }
    let(:delivery) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }

    before do
      allow(Notification::MarkdownConverter).to receive(:to_html).with(newsletter.body).and_return(html)
      allow(UserNotificationMailer).to receive(:notify).with(user, html).and_return(delivery)
    end

    it 'sends newsletter by email' do
      expect { described_class.call newsletter, user }.to change(newsletter, :sent_count).by(1)
      expect(delivery).to have_received(:deliver_now)
      expect(request).not_to have_been_requested
    end
  end

  context 'when request to telegram fails' do
    before do
      request.to_return(status: 400)
      allow(Rollbar).to receive(:error)
    end

    it 'does not send newsletter' do
      expect { described_class.call newsletter, user }.not_to change(newsletter, :sent_count)
      expect(request).to have_been_requested.times(3)
      expect(Rollbar).to have_received(:error).once
    end
  end
end
