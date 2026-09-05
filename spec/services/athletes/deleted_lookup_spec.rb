# frozen_string_literal: true

RSpec.describe Athletes::DeletedLookup, type: :service do
  subject(:lookup) { described_class.call(athlete_id) }

  describe 'when athlete still exists' do
    let(:athlete) { create(:athlete) }
    let(:athlete_id) { athlete.id }

    it 'returns the current record' do
      expect(lookup.status).to eq :exists
      expect(lookup.athlete).to eq athlete
      expect(lookup.snapshot).to be_nil
    end
  end

  describe 'when athletes were reunited' do
    let(:email_user) { create(:user, :with_email) }
    let(:telegram_user) { create(:user) }
    let!(:email_athlete) { create(:athlete, user: email_user, parkrun_code: 111_111) }
    let!(:telegram_athlete) { create(:athlete, user: telegram_user) }
    let(:athlete_id) { telegram_athlete.id }
    let(:ids) { [email_athlete.id, telegram_athlete.id] }

    before do
      Audited.store[:current_request_uuid] = SecureRandom.uuid
      Athletes::Reuniter.call(Athlete.where(id: ids), ids)
    end

    it 'returns the surviving athlete' do
      expect(lookup).to have_attributes(
        status: :reunited,
        athlete: email_athlete,
        merged_at: be_present,
      )
      expect(lookup.snapshot['name']).to eq telegram_athlete.name
    end
  end

  describe 'when athlete was destroyed without reunite' do
    let(:athlete) { create(:athlete, name: 'Иван ТЕСТОВ') }
    let(:athlete_id) { athlete.id }

    before { athlete.destroy! }

    it 'returns the destroy snapshot without a current athlete' do
      expect(lookup.status).to eq :destroyed
      expect(lookup.athlete).to be_nil
      expect(lookup.snapshot['name']).to eq 'Иван ТЕСТОВ'
    end
  end

  describe 'when participation was reassigned without athlete update audit' do
    let(:deleted) { create(:athlete) }
    let(:survivor) { create(:athlete) }
    let!(:volunteer) { create(:volunteer, athlete: deleted) }
    let(:athlete_id) { deleted.id }

    before do
      volunteer.update_columns(athlete_id: survivor.id) # rubocop:disable Rails/SkipsModelValidations -- emulate Reuniter update_all
      deleted.destroy!
    end

    it 'finds the current athlete via participation audits' do
      expect(lookup.status).to eq :reunited
      expect(lookup.athlete).to eq survivor
    end
  end

  describe 'when athlete is unknown' do
    let(:athlete_id) { 99_999_999 }

    it { expect(lookup.status).to eq :not_found }
    it { expect(lookup.athlete).to be_nil }
  end

  describe 'when athlete_id is not positive' do
    let(:athlete_id) { 0 }

    it { expect(lookup.status).to eq :not_found }
  end
end
