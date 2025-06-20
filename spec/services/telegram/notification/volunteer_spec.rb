# frozen_string_literal: true

RSpec.describe Telegram::Notification::Volunteer do
  let(:user) { create(:user) }
  let(:athlete) { create(:athlete, user:) }
  let(:activity) { create(:activity, event:) }
  let(:volunteer) { create(:volunteer, athlete:, activity:) }
  let(:director) { create(:user) }
  let(:event) { create(:event) }
  let(:bot_token) { '123456:aaabbb' }
  let(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/sendMessage}) }

  before do
    stub_const('Telegram::Bot::TOKEN', bot_token)
    allow(Rollbar).to receive(:error)
    request.to_return(status: 200)
    described_class.new(volunteer, director, event).call
  end

  it 'notifies the volunteer' do
    expect(request).to have_been_requested
    expect(Rollbar).not_to have_received(:error)
  end
end
