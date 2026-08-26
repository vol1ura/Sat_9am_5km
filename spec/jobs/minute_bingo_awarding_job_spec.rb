# frozen_string_literal: true

RSpec.describe MinuteBingoAwardingJob do
  let!(:badge) { create(:badge, kind: :minute_bingo) }
  let!(:athlete) { create(:athlete) }

  before do
    60.times do |idx|
      create(:result, athlete: athlete, total_time: (18 * 60) + idx)
    end
  end

  context 'when athlete has not received the badge' do
    let(:expected_date) { athlete.results.published.maximum('activity.date') }

    it 'awards the minute bingo badge' do
      expect { described_class.perform_now }.to change { athlete.trophies.count }.by(1)
      expect(athlete.trophies.sole.date).to eq(expected_date)
    end
  end

  context 'when athlete already has the badge' do
    before { create(:trophy, athlete:, badge:) }

    it 'does not award the badge again' do
      expect { described_class.perform_now }.not_to(change { athlete.trophies.count })
    end
  end

  context 'when some seconds are missing' do
    before { athlete.results.last.destroy }

    it 'does not award the badge' do
      expect { described_class.perform_now }.not_to(change { athlete.trophies.count })
    end
  end
end
