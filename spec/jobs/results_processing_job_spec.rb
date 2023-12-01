RSpec.describe ResultsProcessingJob do
  let(:activity) { create(:activity, date: Date.current) }
  let(:athlete) { create(:athlete) }
  let!(:result) { create(:result, activity: activity, athlete: athlete, position: 1) }

  before do
    create(:result, activity_params: { date: Date.yesterday }, athlete: athlete, position: 2)
  end

  it 'performs immediately' do
    expect { described_class.perform_later(activity.id) }.to have_enqueued_job.on_queue('critical').at(:no_wait)
  end

  it 'awards athlete by badge' do
    expect do
      described_class.perform_now(activity.id)
    end
      .to change { result.reload.personal_best }.to(true)
      .and change { result.reload.first_run }.to(true)
  end
end
