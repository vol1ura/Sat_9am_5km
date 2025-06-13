# frozen_string_literal: true

RSpec.describe RenewGoingToEventJob do
  describe '#perform' do
    let(:event) { create(:event) }
    let(:activity) { create(:activity, date: Date.current.next_occurring(:saturday), event: event) }
    let!(:volunteer) { create(:volunteer, activity:) }

    before { create_list(:athlete, 2, going_to_event_id: event.id) }

    it 'renews going_to_event_id' do
      expect { described_class.perform_now(event.id) }.to change { event.going_athletes.count }.from(2).to(1)
      expect(volunteer.reload.athlete.going_to_event_id).to eq(activity.event_id)
    end
  end
end
