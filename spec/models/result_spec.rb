# frozen_string_literal: true

RSpec.describe Result do
  describe '.time_string' do
    subject { described_class.time_string(time) }

    context 'when time is nil' do
      let(:time) { nil }

      it { is_expected.to eq 'xx:xx' }
    end

    context 'when time is less than 1 hour' do
      let(:time) { 1050 }

      it { is_expected.to eq '17:30' }
    end

    context 'when time is over 1 hour' do
      let(:time) { 3737 }

      it { is_expected.to eq '01:02:17' }
    end
  end

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

  describe '#correct?' do
    subject { result.correct? }

    context 'when total_time is nil' do
      let(:result) { build(:result, total_time: nil) }

      it { is_expected.to be false }
    end

    context 'when athlete is not present' do
      let(:result) { build(:result, athlete: nil, total_time: 1200) }

      it { is_expected.to be true }
    end

    context 'when athlete has name and gender' do
      let(:result) { build(:result, athlete: create(:athlete, name: 'Alex', gender: 'male'), total_time: 1200) }

      it { is_expected.to be true }
    end

    context 'when athlete name is blank' do
      let(:result) { build(:result, athlete: create(:athlete, name: nil, gender: 'male'), total_time: 1200) }

      it { is_expected.to be false }
    end

    context 'when athlete gender is blank' do
      let(:result) { build(:result, athlete: create(:athlete, name: 'Alex', gender: nil), total_time: 1200) }

      it { is_expected.to be false }
    end
  end
end
