# frozen_string_literal: true

RSpec.describe MinuteBingoAwardingJob, type: :job do
  let!(:badge) { create(:badge, kind: :minute_bingo) }
  let!(:athlete) { create(:athlete) }

  before do
    60.times do |idx|
      create(:result, athlete: athlete, total_time: Result.total_time(18, idx))
    end
  end

  context 'when athlete has not received the badge' do
    it 'awards the minute bingo badge' do
      expect { described_class.perform_now }.to change { athlete.trophies.count }.by(1)
    end
  end

  context 'when athlete already has the badge' do
    before { create(:trophy, athlete:, badge:) }

    it 'does not award the badge again' do
      expect { described_class.perform_now }.not_to(change { athlete.trophies.count })
    end
  end
end
