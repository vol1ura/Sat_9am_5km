# frozen_string_literal: true

RSpec.describe Permission do
  describe 'validations' do
    it { is_expected.not_to be_valid }

    it 'valid with user, action and subject_class' do
      permission = build_stubbed(:permission)
      expect(permission).to be_valid
    end
  end
end
