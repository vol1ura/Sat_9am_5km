RSpec.describe Permission, type: :model do
  it { is_expected.not_to be_valid }

  it 'valid with user, action and subject_class' do
    permission = create :permission
    expect(permission).to be_valid
  end
end
