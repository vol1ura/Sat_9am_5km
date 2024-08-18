# frozen_string_literal: true

RSpec.describe AddAthleteToResultJob do
  let(:activity) { create(:activity) }
  let(:result) { create(:result, activity: activity, athlete: result_athlete) }
  let(:athlete) { create(:athlete) }

  before { described_class.perform_now(activity.id, "A#{athlete.parkrun_code}", "P#{result.position}") }

  context 'without athlete' do
    let(:result_athlete) { nil }

    it 'updates result' do
      expect(result.reload.athlete_id).to eq athlete.id
    end
  end

  context 'with another athlete' do
    let(:result_athlete) { create(:athlete) }

    it 'creates new result' do
      expect(activity.results.pluck(:athlete_id)).to include(athlete.id, result_athlete.id)
    end
  end
end
