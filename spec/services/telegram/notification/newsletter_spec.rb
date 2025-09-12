# frozen_string_literal: true

RSpec.describe Telegram::Notification::Newsletter, type: :service do
  let(:user) { create(:user) }
  let(:bot_token) { '123456:aaabbb' }
  let(:telegram_method) { 'sendMessage' }
  let!(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/#{telegram_method}}) }
  let(:newsletter) { create(:newsletter) }

  before { stub_const('Telegram::Bot::TOKEN', bot_token) }

  shared_examples 'successfully sends newsletter' do
    specify do
      described_class.call(newsletter, user)
      expect(request).to have_been_requested
    end
  end

  it_behaves_like 'successfully sends newsletter'

  context 'with image' do
    let(:telegram_method) { 'sendPhoto' }
    let(:newsletter) { create(:newsletter, picture_link: Faker::Internet.url(host: 'test.com', path: '/pic.png')) }

    it_behaves_like 'successfully sends newsletter'
  end

  context 'when request to telegram fails' do
    before do
      request.to_return(status: 400)
      allow(Rollbar).to receive(:error)
    end

    it 'does not send newsletter' do
      described_class.call(newsletter, user)
      expect(request).to have_been_requested.times(3)
      expect(Rollbar).to have_received(:error).once
    end
  end
end
