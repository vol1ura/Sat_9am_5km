# frozen_string_literal: true

RSpec.describe Metrics::VolunteerBusFactorCalculator do
  describe '.call' do
    let(:event) { create(:event, active: true) }

    it 'returns a positive number' do
      result = described_class.call(event)
      expect(result).to be >= 0
    end

    it 'considers volunteer distribution across roles' do
      activity = create(:activity, event: event, published: true)
      create_list(:volunteer, 5, activity: activity, role: :timer)
      create_list(:volunteer, 3, activity: activity, role: :marshal)

      result = described_class.call(event)
      expect(result).to be > 0
    end
  end
end
