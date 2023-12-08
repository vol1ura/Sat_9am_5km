RSpec.describe HomeBadgeAwardingJob do
  it 'performs immediately' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end
end
