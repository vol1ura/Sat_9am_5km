# frozen_string_literal: true

RSpec.describe Athletes::StatsUpdate, type: :service do
  context 'when reunite athletes with trophies' do
    let(:athlete) { create(:athlete) }
    let(:expected_stats) do
      {
        'results' => {
          'count' => 1,
          'h_index' => 1,
          'current_streak' => 1,
          'longest_streak' => 1,
          'trophies' => 1,
          'uniq_events' => 1,
        },
        'volunteers' => {
          'count' => 1,
          'h_index' => 1,
          'current_streak' => 1,
          'longest_streak' => 1,
          'trophies' => 1,
          'uniq_events' => 1,
        },
      }
    end

    before do
      activity_params = { date: Date.current }
      create(:result, athlete:, activity_params:)
      create(:volunteer, athlete:, activity_params:)
      create(:trophy, athlete:)
    end

    it 'returns true' do
      expect { described_class.call(athlete) }.to change(athlete, :stats).from({}).to(expected_stats)
    end
  end
end
