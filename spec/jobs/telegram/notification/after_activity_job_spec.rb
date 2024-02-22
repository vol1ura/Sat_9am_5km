# frozen_string_literal: true

RSpec.describe Telegram::Notification::AfterActivityJob do
  it 'performs immediately' do
    expect { described_class.perform_later(1) }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  context 'with published activity' do
    let(:activity) { create(:activity) }
    let(:athlete) { create(:athlete, user: create(:user)) }

    before do
      create(:result, activity:, athlete:)
      create(:volunteer, activity:, athlete:)
      allow(Telegram::Notification::AfterActivity::Result).to receive(:call)
      allow(Telegram::Notification::AfterActivity::Volunteer).to receive(:call)
    end

    it 'informs athlete' do
      described_class.perform_now(activity.id)
      expect(Telegram::Notification::AfterActivity::Result).to have_received(:call).once
      expect(Telegram::Notification::AfterActivity::Volunteer).to have_received(:call).once
    end
  end
end
