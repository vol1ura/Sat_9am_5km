# frozen_string_literal: true

RSpec.describe Notification::BreakingTimeBadgesExpirationJob do
  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  describe '#perform' do
    let(:badge) { create(:badge, kind: :breaking, info: { gender: 'male', sec: 18 * 60 }) }
    let(:threshold_date) { BreakingTimeAwardingJob::EXPIRATION_PERIOD.ago.to_date + 1.week }

    before { allow(Notification::Badge::BreakingTimeExpiration).to receive(:call) }

    it 'notifies about expiring trophies' do
      not_expiring_trophy = create(:trophy, badge: badge, date: threshold_date + 1.day)
      expiring_trophy = create(:trophy, badge: badge, date: threshold_date - 1.day)

      described_class.perform_now

      expect(Notification::Badge::BreakingTimeExpiration).to have_received(:call).with(expiring_trophy)
      expect(Notification::Badge::BreakingTimeExpiration).not_to have_received(:call).with(not_expiring_trophy)
    end
  end
end
