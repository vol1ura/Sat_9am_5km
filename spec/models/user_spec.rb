# frozen_string_literal: true

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

    it 'valid with telegram_id but without email and password' do
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.telegram_id = Faker::Number.number(digits: 10)
      expect(user).to be_valid
    end

    it 'invalid without email and telegram_id' do
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('не может быть пустым')
    end

    it 'invalid without password when email is present' do
      user.first_name = Faker::Name.first_name
      user.last_name = Faker::Name.last_name
      user.email = Faker::Internet.email
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('не может быть пустым')
    end

    it 'resets emergency_contact_name' do
      user = create(
        :user,
        emergency_contact_phone: '+79261234567',
        emergency_contact_name: Faker::Name.name,
      )
      user.emergency_contact_phone = nil
      expect(user).to be_valid
      expect(user.emergency_contact_name).to be_nil
    end

    it 'invalid with non existent promotion' do
      user = create(:user)
      user.promotions << :invalid
      expect(user).not_to be_valid
    end
  end
end
