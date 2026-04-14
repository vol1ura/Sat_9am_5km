# frozen_string_literal: true

RSpec.describe Notification::RageBadgesExpirationJob do
  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  describe '#perform' do
    let(:badge) { create(:badge, kind: :rage) }
    let(:target_date) { Date.current.prev_week(:saturday) }

    before { allow(Notification::Badge::RageExpiration).to receive(:call) }

    it 'notifies about expiring rage trophies' do
      expiring_trophy = create(:trophy, badge: badge, date: target_date)
      not_expiring_trophy = create(:trophy, badge: badge, date: target_date - 1.week)

      described_class.perform_now

      expect(Notification::Badge::RageExpiration).to have_received(:call).with(expiring_trophy)
      expect(Notification::Badge::RageExpiration).not_to have_received(:call).with(not_expiring_trophy)
    end
  end
end
