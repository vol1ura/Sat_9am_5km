# frozen_string_literal: true

RSpec.describe Notification::BeforeActivityJob do
  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  describe '#perform' do
    let!(:event) { create(:event) }

    before do
      allow(Notification::VolunteerJob).to receive(:set).and_return(Notification::VolunteerJob)
      allow(RenewGoingToEventJob).to receive(:set).and_return(RenewGoingToEventJob)
    end

    it 'schedules volunteer notification and renew going for each event' do
      expect { described_class.perform_now }
        .to have_enqueued_job(Notification::VolunteerJob).with(event.id)
        .and have_enqueued_job(RenewGoingToEventJob).with(event.id)

      expect(Notification::VolunteerJob)
        .to have_received(:set).with(wait_until: an_instance_of(ActiveSupport::TimeWithZone))
      expect(RenewGoingToEventJob).to have_received(:set).with(wait_until: an_instance_of(ActiveSupport::TimeWithZone))
    end
  end
end
