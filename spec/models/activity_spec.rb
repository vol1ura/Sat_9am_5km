# frozen_string_literal: true

RSpec.describe Activity, type: :model do
  let(:activity) { build :activity }

  describe 'validations' do
    it { is_expected.not_to be_valid }

    it 'valid with event' do
      expect(activity).to be_valid
    end
  end

  describe '#leader_result' do
    it 'returns best male result' do
      FactoryBot.rewind_sequences
      activity = create :activity
      activity.results << build_list(:result, 3, activity_id: nil)
      expect(activity.leader_result.position).to eq 1
    end
  end
end
