# frozen_string_literal: true

RSpec.describe ResetGoingAthletesJob do
  describe '#perform' do
    let(:event) { create(:event) }
    let(:activity) { create(:activity, date: Date.current.next_occurring(:saturday)) }
    let!(:volunteer) { create(:volunteer, activity:) }

    before { create_list(:athlete, 2, going_to_event_id: event.id) }

    it 'resets going_to_event_id' do
      expect { described_class.perform_now }.to change { event.going_athletes.count }.from(2).to(0)
      expect(volunteer.reload.athlete.going_to_event_id).to eq(activity.event_id)
    end
  end
end
