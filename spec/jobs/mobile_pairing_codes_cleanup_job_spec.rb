# frozen_string_literal: true

RSpec.describe MobilePairingCodesCleanupJob do
  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  describe '#perform' do
    let(:user) { create(:user) }

    def create_code(**attrs)
      user.mobile_pairing_codes.create!(
        code_digest: 'digest',
        expires_at: 5.minutes.from_now,
        **attrs,
      )
    end

    it 'deletes codes expired more than a day ago' do
      recently_consumed = create_code(consumed_at: Time.current)
      recently_expired = create_code(expires_at: 1.minute.ago)
      stale = create_code(expires_at: 1.day.ago)

      expect { described_class.perform_now }.to change(MobilePairingCode, :count).by(-1)
      expect(MobilePairingCode).to exist(id: recently_consumed.id)
      expect(MobilePairingCode).to exist(id: recently_expired.id)
      expect(MobilePairingCode).not_to exist(id: stale.id)
    end
  end
end
