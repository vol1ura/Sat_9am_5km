# frozen_string_literal: true

RSpec.describe Telegram::Notification::Badge::RageExpiration, type: :service do
  let(:athlete) { create(:athlete, user: create(:user)) }
  let(:date) { Date.current.prev_week(:saturday) }
  let(:rage_trophy) do
    create(
      :trophy,
      athlete: athlete,
      badge: create(:badge, kind: :rage),
      date: date,
    )
  end
  let(:bot_token) { '123456:aaabbb' }
  let!(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/sendMessage}) }

  before do
    stub_const('Telegram::Bot::TOKEN', bot_token)
    create(:result, athlete: athlete, activity_params: { date: })
  end

  context 'when request to telegram successful' do
    it 'informs athlete' do
      described_class.call(rage_trophy)
      expect(request).to have_been_requested
    end
  end

  context 'when request to telegram fails' do
    before { request.to_raise(StandardError) }

    it 'not informs athlete' do
      described_class.call(rage_trophy)
      expect(request).to have_been_requested
    end
  end
end
