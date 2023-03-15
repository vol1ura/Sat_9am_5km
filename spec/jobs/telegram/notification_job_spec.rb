RSpec.describe Telegram::NotificationJob do
  let(:activity) { create(:activity) }
  let(:athlete) { create(:athlete, user: create(:user)) }

  before do
    create(:result, activity: activity, athlete: athlete)
    create(:volunteer, activity: activity, athlete: athlete)
    allow(Telegram::Informer::Result).to receive(:call)
    allow(Telegram::Informer::Volunteer).to receive(:call)
  end

  it 'performs immediately' do
    expect { described_class.perform_later(activity.id) }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  it 'informs athlete' do
    described_class.perform_now(activity.id)
    expect(Telegram::Informer::Result).to have_received(:call).once
    expect(Telegram::Informer::Volunteer).to have_received(:call).once
  end
end
