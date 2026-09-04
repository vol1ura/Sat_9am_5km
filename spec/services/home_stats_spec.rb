# frozen_string_literal: true

RSpec.describe HomeStats, type: :service do
  subject(:stats) { described_class.call(:ru) }

  let(:event) { create(:event) }
  let(:activity) { create(:activity, event: event, published: true) }
  let(:athlete) { create(:athlete) }

  before do
    create(:result, activity:, athlete:)
    create(:volunteer, activity:, athlete:)
  end

  it 'returns published stats for the country' do
    expect(stats).to eq(
      events: 1,
      activities: 1,
      participants: 1,
      finishes: 1,
      volunteers: 1,
      volunteerings: 1,
    )
  end
end
