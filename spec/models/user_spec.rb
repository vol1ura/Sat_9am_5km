RSpec.describe User do
  describe 'validation' do
    subject(:user) { described_class.new }

    it { is_expected.not_to be_valid }

    it 'valid with email and password' do
      user.password = Faker::Internet.password(min_length: 6)
      user.email = Faker::Internet.free_email
      expect(user).to be_valid
    end

    it 'invalid with existing email' do
      email = Faker::Internet.free_email
      create(:user, email: email)
      another_user = build(:user, email: email)
      expect(another_user).not_to be_valid
    end
  end
end
