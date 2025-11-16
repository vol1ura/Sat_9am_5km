# frozen_string_literal: true

RSpec.describe Result do
  describe 'validation' do
    subject { described_class.new }

    it { is_expected.not_to be_valid }

    it 'valid with user and activity' do
      result = build(:result)
      expect(result).to be_valid
    end
  end

  describe '#swap_with_position!' do
    let(:activity) { create(:activity) }
    let(:athlete_first) { create(:athlete) }
    let(:athlete_second) { create(:athlete) }
    let!(:result_first) { create(:result, activity: activity, position: 1, athlete: athlete_first) }
    let!(:result_second) { create(:result, activity: activity, position: 2, athlete: athlete_second) }

    it 'moves result up' do
      expect do
        result_second.swap_with_position!(1)
      end.to change(result_second, :athlete_id).from(athlete_second.id).to(athlete_first.id)
    end

    it 'returns changed result' do
      pred_result = result_second.swap_with_position!(1)
      expect(pred_result).to have_attributes(id: result_first.id, position: 1)
    end

    it 'moves result down' do
      expect do
        result_first.swap_with_position!(2)
      end.to change(result_first, :athlete_id).from(athlete_first.id).to(athlete_second.id)
    end
  end
end
