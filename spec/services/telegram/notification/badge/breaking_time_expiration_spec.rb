# frozen_string_literal: true

RSpec.describe Telegram::Notification::Badge::BreakingTimeExpiration, type: :service do
  fixtures :badges

  let(:trophy) do
    create(
      :trophy,
      athlete: create(:athlete, user: create(:user)),
      badge: Badge.breaking_kind.find_by("(info->'male')::boolean = ?", true),
      date: BreakingTimeAwardingJob::EXPIRATION_PERIOD.months.ago,
    )
  end
  let(:bot_token) { '123456:aaabbb' }
  let!(:request) { stub_request(:post, %r{https://api\.telegram\.org/bot#{bot_token}/sendMessage}) }

  before { stub_const('Telegram::Bot::TOKEN', bot_token) }

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
