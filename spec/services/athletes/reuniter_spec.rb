# frozen_string_literal: true

RSpec.describe Athletes::Reuniter, type: :service do
  subject(:service) { described_class.call(collection, ids) }

  context 'when reuniting athletes with email and telegram users' do
    let(:email_user) { create(:user, :with_email) }
    let(:telegram_user) { create(:user) }
    let!(:email_athlete) { create(:athlete, user: email_user, parkrun_code: '111111') }
    let!(:telegram_athlete) { create(:athlete, user: telegram_user) }
    let(:ids) { [email_athlete.id, telegram_athlete.id] }
    let(:collection) { Athlete.where(id: ids) }
    let(:telegram_id) { telegram_user.telegram_id }
    let(:telegram_username) { telegram_user.telegram_user }

    it 'merges users and athletes' do
      expect(service).to be true
      expect(Athlete.where(id: ids)).to be_one
      email_user.reload
      expect(email_user.telegram_id).to eq telegram_id
      expect(email_user.telegram_user).to eq telegram_username
    end

    context 'when telegram user has extra profile data' do
      let(:telegram_user) { create(:user, phone: '+79001234567', with_avatar: true) }

      it 'transfers blank fields to the email user' do
        expect(service).to be true

        email_user.reload
        expect(email_user.phone).to eq '+79001234567'
        expect(email_user.image).to be_attached
      end
    end

    context 'when email user already has another telegram account' do
      let(:email_user) { create(:user, :with_email, telegram_id: 111) }
      let(:telegram_user) { create(:user, telegram_id: 222) }

      it { is_expected.to be false }
    end
  end

  context 'when reuniting athletes with two email users' do
    let(:first_user) { create(:user, :with_email) }
    let(:second_user) { create(:user, :with_email) }
    let!(:first_athlete) { create(:athlete, user: first_user) }
    let!(:second_athlete) { create(:athlete, user: second_user) }
    let(:ids) { [first_athlete.id, second_athlete.id] }
    let(:collection) { Athlete.where(id: ids) }

    it { is_expected.to be false }
  end

  context 'when reunite athletes with trophies' do
    let(:badge) { create(:badge) }
    let(:trophy) { create(:trophy) }
    let(:trophies) { create_list(:trophy, 2, badge:) }
    let(:ids) { trophies.map(&:athlete_id) + [trophy.athlete_id] }
    let(:collection) { Athlete.where(id: ids) }

    it { is_expected.to be true }

    context 'when some modified attribute was ignored' do
      before { stub_const('Athletes::Reuniter::SKIPPED_ATTRIBUTES', []) }

      it { is_expected.to be false }
    end
  end
end
