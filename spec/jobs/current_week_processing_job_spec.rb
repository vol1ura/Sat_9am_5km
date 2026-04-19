# frozen_string_literal: true

RSpec.describe CurrentWeekProcessingJob do
  let(:event) { create(:event) }
  let(:activity) { create(:activity, event: event, date: Date.current.beginning_of_week(:monday)) }

  before do
    [ResultsProcessingJob, AthletesAwardingJob, FivePlusAwardingJob, EventRecordAwardingJob].each do |job|
      allow(job).to receive(:perform_now)
    end
  end

  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  it 'processes published activities of the current week' do
    activity
    described_class.perform_now

    expect(ResultsProcessingJob).to have_received(:perform_now).with(activity.id)
    expect(AthletesAwardingJob).to have_received(:perform_now).with(activity.id)
    expect(FivePlusAwardingJob).to have_received(:perform_now).with(activity.id, with_expiration: true)
    expect(EventRecordAwardingJob).to have_received(:perform_now).with(event.id)
  end

  it 'skips unpublished activities' do
    create(:activity, event: event, date: Date.current, published: false)
    described_class.perform_now

    expect(ResultsProcessingJob).not_to have_received(:perform_now)
  end

  it 'marks old uninformed results as informed' do
    old_activity = create(:activity, event: event, date: 2.weeks.ago)
    result = create(:result, activity: old_activity, informed: false)
    volunteer = create(:volunteer, activity: old_activity, informed: false)
    recent_result = create(:result, activity: activity, informed: false)

    described_class.perform_now

    expect(result.reload.informed).to be true
    expect(volunteer.reload.informed).to be true
    expect(recent_result.reload.informed).to be false
  end
end
