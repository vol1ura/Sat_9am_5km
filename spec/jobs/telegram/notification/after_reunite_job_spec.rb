# frozen_string_literal: true

RSpec.describe Telegram::Notification::AfterReuniteJob do
  specify { expect { described_class.perform_later(1) }.to have_enqueued_job.on_queue('low').at(:no_wait) }

  context 'when runs' do
    let(:user) { create(:user) }

    before do
      allow(Telegram::Notification::User::Reunite).to receive(:call)
      described_class.perform_now(user.id)
    end

    specify { expect(Telegram::Notification::User::Reunite).to have_received(:call).with(user).once }
  end
end
