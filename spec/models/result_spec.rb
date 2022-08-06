RSpec.describe Result, type: :model do
  describe 'validation' do
    subject { described_class.new }

    it { is_expected.not_to be_valid }

    it 'valid with user and activity' do
      result = build :result
      expect(result).to be_valid
    end
  end

  describe '#swap_with_position' do
    let(:activity) { create :activity }
    let(:athlete1) { create :athlete }
    let(:athlete2) { create :athlete }
    let!(:result1) { create :result, activity: activity, position: 1, athlete: athlete1 }
    let!(:result2) { create :result, activity: activity, position: 2, athlete: athlete2 }

    it 'moves result up' do
      expect do
        result2.swap_with_position(1)
      end.to change(result2, :athlete_id).from(athlete2.id).to(athlete1.id)
    end

    it 'returns changed result' do
      pred_result = result2.swap_with_position(1)
      expect(pred_result).to have_attributes(id: result1.id, position: 1)
    end

    it 'moves result down' do
      expect do
        result1.swap_with_position(2)
      end.to change(result1, :athlete_id).from(athlete1.id).to(athlete2.id)
    end
  end

  describe '#shift_attributes' do
    it 'shift time in protocol'
    it 'shift athlete in protocol'
  end
end
