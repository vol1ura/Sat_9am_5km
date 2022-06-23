RSpec.describe Result, type: :model do
  describe 'validation' do
    subject { described_class.new }

    it { is_expected.not_to be_valid }

    it 'valid with user and activity' do
      result = build :result
      expect(result).to be_valid
    end
  end
end
