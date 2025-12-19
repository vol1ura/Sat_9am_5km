# frozen_string_literal: true

RSpec.describe AthletePersonalBestsUpdateJob do
  let(:athlete) { create(:athlete) }

  it 'enqueues immediately' do
    expect { described_class.perform_later(athlete.id) }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  describe '#perform' do
    let(:first_activity) { create(:activity, date: 1.week.ago) }
    let(:second_activity) { create(:activity, date: 1.day.ago) }
    let(:unpublished_activity) { create(:activity, date: 1.month.ago, published: false) }

    before do
      allow(ResultsProcessingJob).to receive(:perform_now)

      create(:result, athlete: athlete, activity: second_activity)
      create(:result, athlete: athlete, activity: first_activity)
      create(:result, athlete: athlete, activity: unpublished_activity)
    end

    it 'reprocesses published results in chronological order' do
      described_class.perform_now(athlete.id)

      expect(ResultsProcessingJob)
        .to have_received(:perform_now)
        .with(first_activity.id).ordered
      expect(ResultsProcessingJob)
        .to have_received(:perform_now)
        .with(second_activity.id).ordered
      expect(ResultsProcessingJob)
        .not_to have_received(:perform_now)
        .with(unpublished_activity.id)
    end
  end
end
