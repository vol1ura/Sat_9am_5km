# frozen_string_literal: true

RSpec.describe Metrics::LocationHealthCalculator do
  describe '.call' do
    let(:event) { create(:event, active: true) }

    context 'when event is inactive' do
      let(:event) { create(:event, active: false) }

      it 'returns 0' do
        expect(described_class.call(event)).to eq(0)
      end
    end

    context 'when event is active' do
      it 'returns a value between 0 and 100' do
        result = described_class.call(event)
        expect(result).to be_between(0, 100).inclusive
      end

      it 'considers activity frequency' do
        create_list(:activity, 3, event: event, published: true, date: 2.months.ago.to_date)
        result = described_class.call(event)
        expect(result).to be > 0
      end

      it 'considers volunteer consistency' do
        athlete = create(:athlete)
        activity = create(:activity, event: event, published: true, date: 2.months.ago.to_date)
        create(:volunteer, athlete: athlete, activity: activity, role: :timer)

        result = described_class.call(event)
        expect(result).to be > 0
      end
    end
  end
end
