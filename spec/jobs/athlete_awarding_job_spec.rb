RSpec.describe AthleteAwardingJob, type: :job do
  ActiveJob::Base.queue_adapter = :test

  fixtures :badges

  let(:event) { create :event }
  let(:athlete) { create :athlete }
  let(:activity) { create :activity, date: Time.zone.today, event: event }

  before do
    24.times do |idx|
      activity = create :activity, event: event, date: idx.next.week.ago
      create :result, athlete: athlete, activity: activity
      create :volunteer, athlete: athlete, activity: activity
    end
  end

  it 'performs immediately' do
    expect { described_class.perform_later(activity.id) }.to have_enqueued_job.on_queue('default').at(:no_wait)
  end

  it 'creates new trophies' do
    create :result, activity: activity, athlete: athlete
    create :volunteer, activity: activity, athlete: athlete
    expect do
      described_class.perform_now(activity.id)
    end.to change(athlete.trophies, :count).by(2)
  end
end
