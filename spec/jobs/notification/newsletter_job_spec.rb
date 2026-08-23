# frozen_string_literal: true

RSpec.describe Notification::NewsletterJob do
  let(:newsletter) { create(:newsletter) }
  let(:user) { create(:user, disabled_notifications:) }
  let(:notification_type) { :newsletter }
  let(:disabled_notifications) { [] }

  specify do
    expect { described_class.perform_later(newsletter.id, user.id, notification_type) }
      .to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  describe '#perform' do
    before { allow(Notification::Newsletter).to receive(:call) }

    context 'when notification is enabled' do
      before { described_class.perform_now(newsletter.id, user.id, notification_type) }

      it 'sends newsletter' do
        expect(Notification::Newsletter).to have_received(:call).with(newsletter, user, increment: true).once
      end
    end

    context 'when notification is disabled' do
      let(:disabled_notifications) { %w[newsletter] }

      before { described_class.perform_now(newsletter.id, user.id, notification_type) }

      it 'does not send newsletter' do
        expect(Notification::Newsletter).not_to have_received(:call)
      end
    end
  end
end
