# frozen_string_literal: true

RSpec.describe ResultsProcessingJob do
  it 'performs immediately' do
    expect { described_class.perform_later(1) }.to have_enqueued_job.on_queue('critical').at(:no_wait)
  end

  context 'with results' do
    let(:activity) { create(:activity, date: Date.current) }
    let(:athlete) { create(:athlete) }
    let!(:result) do
      create(:result, activity: activity, athlete: athlete, position: 1, personal_best: false, first_run: false)
    end

    before { create(:result, activity_params: { date: Date.yesterday }, athlete: athlete, position: 2) }

    it 'awards athlete by badge' do
      expect do
        described_class.perform_now(activity.id)
      end
        .to change { result.reload.personal_best }.to(true)
        .and change { result.reload.first_run }.to(true)
    end
  end
end
