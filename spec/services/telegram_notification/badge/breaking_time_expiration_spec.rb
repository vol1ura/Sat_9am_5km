# frozen_string_literal: true

RSpec.describe TelegramNotification::Badge::BreakingTimeExpiration, type: :service do
  let(:trophy) do
    create(
      :trophy,
      athlete: create(:athlete, user: create(:user)),
      badge: Badge.breaking_kind.where("(info->'male')::boolean = ?", true).take,
      date: BreakingTimeAwardingJob::EXPIRATION_PERIOD.months.ago
    )
  end
  let(:bot_token) { '123456:aaabbb' }
  let!(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/sendMessage}) }

  before { stub_const('TelegramNotification::Bot::TOKEN', bot_token) }

  context 'when request to telegram successful' do
    it 'informs athlete' do
      described_class.call(trophy)
      expect(request).to have_been_requested
    end
  end

  context 'when request to telegram fails' do
    before { request.to_raise(StandardError) }

    it 'not informs athlete' do
      described_class.call(trophy)
      expect(request).to have_been_requested
    end
  end
end
