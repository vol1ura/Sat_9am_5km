RSpec.describe AddAthleteToResultJob, type: :job do
  ActiveJob::Base.queue_adapter = :test

  it 'performs immediately' do
    expect { described_class.perform_later }.to have_enqueued_job.at(:no_wait)
  end
end
