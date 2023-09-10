# frozen_string_literal: true

RSpec.describe AthleteReuniter, type: :service do
  context 'when reunite athletes with trophies' do
    let(:badge) { create(:badge) }
    let(:trophy) { create(:trophy) }
    let(:trophies) { create_list(:trophy, 2, badge:) }
    let(:ids) { trophies.map(&:athlete_id) + [trophy.athlete_id] }
    let(:collection) { Athlete.where(id: ids) }

    it 'returns true' do
      expect(described_class.call(collection, ids)).to be_truthy
    end
  end
end
