RSpec.describe AthleteAwardingJob, type: :job do
  ActiveJob::Base.queue_adapter = :test

  fixtures :badges

  let(:event) { create :event }
  let(:activity) { create :activity, date: Time.zone.today, event: event }
  let(:athlete) { create :athlete }

  it 'performs immediately' do
    expect { described_class.perform_later(activity) }.to have_enqueued_job.on_queue('default').at(:no_wait)
  end

  it 'creates new trophies' do
    create_list :result, 24, athlete: athlete
    create :result, activity: activity, athlete: athlete
    create_list :volunteer, 24, athlete: athlete
    create :volunteer, activity: activity, athlete: athlete
    expect do
      described_class.perform_now(activity)
    end.to change(athlete.trophies, :count).by(2)
  end
end
