# frozen_string_literal: true

RSpec.describe Notification::AfterActivity::Volunteer do
  let(:volunteer) { create(:volunteer, athlete: create(:athlete, user: create(:user))) }
  let(:bot_token) { '123456:aaabbb' }
  let!(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/sendMessage}) }

  before { stub_const('Telegram::Bot::TOKEN', bot_token) }

  context 'when request to telegram successful' do
    it 'informs volunteer' do
      described_class.call(volunteer)
      expect(request).to have_been_requested
      expect(volunteer.reload).to be_informed
    end
  end

  context 'when request to telegram fails' do
    before do
      request.to_raise(StandardError)
      allow(Rollbar).to receive(:error)
    end

    it 'does not inform volunteer' do
      described_class.call(volunteer)
      expect(request).to have_been_requested.times(3)
      expect(volunteer.reload).not_to be_informed
      expect(Rollbar).to have_received(:error).once
    end
  end
end
