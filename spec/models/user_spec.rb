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

  describe '#notification_disabled?' do
    let(:user) { build(:user, disabled_notifications: %w[newsletter badge]) }

    it 'returns true for disabled notification type' do
      expect(user.notification_disabled?(:newsletter)).to be true
      expect(user.notification_disabled?(:badge)).to be true
    end

    it 'returns false for enabled notification type' do
      expect(user.notification_disabled?(:after_activity)).to be false
      expect(user.notification_disabled?(:other)).to be false
    end

    it 'returns false when disabled_notifications is empty' do
      user.disabled_notifications = []
      expect(user.notification_disabled?(:newsletter)).to be false
    end
  end

  describe 'sanitize_disabled_notifications' do
    let(:user) { create(:user) }

    it 'removes invalid values on save' do
      user.update!(disabled_notifications: %w[newsletter invalid_type badge fake])
      expect(user.disabled_notifications).to eq %w[newsletter badge]
    end
  end

  describe '#toggle_favorite_event' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    it 'adds event to favorites' do
      user.toggle_favorite_event(event)
      expect(user.favorite_event_ids).to include(event.id)
    end

    it 'removes event from favorites' do
      user.update!(favorite_event_ids: [event.id])
      user.toggle_favorite_event(event)
      expect(user.favorite_event_ids).not_to include(event.id)
    end
  end

  describe '#favorite_events' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    it 'returns events matching favorite_event_ids' do
      user.update!(favorite_event_ids: [event.id])
      expect(user.favorite_events).to include(event)
    end

    it 'returns empty relation when no favorites' do
      expect(user.favorite_events).to be_empty
    end
  end
end
