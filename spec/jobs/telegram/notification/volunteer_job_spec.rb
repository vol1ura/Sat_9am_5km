# frozen_string_literal: true

RSpec.describe Telegram::Notification::VolunteerJob do
  specify { expect { described_class.perform_later(1) }.to have_enqueued_job.on_queue('low').at(:no_wait) }

  context 'when runs' do
    let(:event) { activity.event }
    let(:activity) { create(:activity, published: false, date: Time.zone.tomorrow) }

    before do
      allow(Telegram::Bot).to receive(:call)
      create(:volunteer, role: :director, activity: activity, athlete: create(:athlete, :with_user))
      create(:volunteer, activity: activity, athlete: create(:athlete, :with_user))

      described_class.perform_now(event.id)
    end

    it 'sends notifications' do
      expect(Telegram::Bot).to have_received(:call).twice
    end
  end
end
