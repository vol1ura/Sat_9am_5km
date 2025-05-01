# frozen_string_literal: true

RSpec.describe Athletes::DuplicatesFinder do
  describe '.call' do
    let!(:parkrun_athlete) { create(:athlete, name: 'Test Name', fiveverst_code: nil) }
    let!(:fiveverst_athlete) { create(:athlete, name: 'Name TEST', parkrun_code: nil) }

    it 'finds duplicated athletes by name case insensitive' do
      expect(described_class.call.size).to eq 2
    end

    it 'finds duplicated athletes by specific name' do
      result = Athlete.where(id: described_class.call(name: 'Test NaMe'))
      expect(result.size).to eq 2
      expect(result).to include(fiveverst_athlete, parkrun_athlete)
    end
  end
end
