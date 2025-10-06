# frozen_string_literal: true

RSpec.describe ScannerProcessingJob do
  let(:activity) { create(:activity, published: false) }
  let(:result) { create(:result, activity: activity, athlete: result_athlete) }
  let(:athlete) { create(:athlete) }

  before do
    described_class.perform_now(activity.id, [{ code: "A#{athlete.parkrun_code}", position: "P#{result.position}" }])
  end

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

  context 'with incorrect result' do
    let(:result) { build(:result, activity: activity, athlete: athlete, position: other_result.position + 1) }
    let(:other_result) { create(:result, activity:, athlete:) }

    it 'alerts about incorrect result' do
      expect(Telegram::Notification::ActivityAlertJob).to have_been_enqueued.with(
        activity.id,
        %w[director results_handler],
        include("проверьте позицию *P#{result.position}*, а также участника с ID *A#{athlete.code}* на дублирование"),
      )
    end
  end
end
