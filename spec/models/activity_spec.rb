# frozen_string_literal: true

RSpec.describe Activity do
  let(:activity) { build(:activity, published: false) }

  describe 'validations' do
    it { is_expected.not_to be_valid }

    it 'valid with event' do
      expect(activity).to be_valid
    end

    it 'invalid with duplicated token' do
      token = SecureRandom.uuid
      create(:activity, token:)
      expect(build(:activity, token:)).not_to be_valid
    end

    it 'valid when token is nil' do
      create(:activity, token: nil)
      expect(build(:activity, token: nil)).to be_valid
    end
  end

  describe '#leader_result' do
    it 'returns best male result' do
      FactoryBot.rewind_sequences
      activity.results << build_list(:result, 3, activity_id: nil)
      activity.save!
      expect(activity.leader_result(:male).position).to eq 1
    end
  end
end
