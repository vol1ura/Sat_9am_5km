RSpec.describe User do
  describe 'validation' do
    subject(:user) { described_class.new }

    it { is_expected.not_to be_valid }

    it 'valid with first_name, last_name, email and password' do
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.password = Faker::Internet.password(min_length: 6)
      user.email = Faker::Internet.email
      expect(user).to be_valid
    end

    it 'invalid with existing email' do
      email = Faker::Internet.email
      create(:user, email:)
      another_user = build(:user, email:)
      expect(another_user).not_to be_valid
    end
  end
end
