# frozen_string_literal: true

RSpec.describe ResetGoingAthletesJob do
  describe '#perform' do
    let(:event) { create(:event) }

    before { create_list(:athlete, 2, going_to_event_id: event.id) }

    it 'resets going_to_event_id for athletes associated with the event' do
      expect { described_class.perform_now(event.id) }.to change { event.going_athletes.count }.from(2).to(0)
    end
  end
end
