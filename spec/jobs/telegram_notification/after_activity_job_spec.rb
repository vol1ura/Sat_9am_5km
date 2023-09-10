RSpec.describe TelegramNotification::AfterActivityJob do
  let(:activity) { create(:activity) }
  let(:athlete) { create(:athlete, user: create(:user)) }

  before do
    create(:result, activity:, athlete:)
    create(:volunteer, activity:, athlete:)
    allow(TelegramNotification::AfterActivity::Result).to receive(:call)
    allow(TelegramNotification::AfterActivity::Volunteer).to receive(:call)
  end

  it 'performs immediately' do
    expect { described_class.perform_later(activity.id) }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  it 'informs athlete' do
    described_class.perform_now(activity.id)
    expect(TelegramNotification::AfterActivity::Result).to have_received(:call).once
    expect(TelegramNotification::AfterActivity::Volunteer).to have_received(:call).once
  end
end
