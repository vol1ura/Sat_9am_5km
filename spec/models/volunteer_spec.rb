# frozen_string_literal: true

RSpec.describe Volunteer do
  describe '.incorrect_on_running_positions' do
    let(:ok_activity) { create(:activity, published: true, date: 1.week.ago.to_date) }
    let(:no_results_activity) { create(:activity, published: true, date: 1.week.ago.to_date) }
    let(:unpublished_activity) { create(:activity, published: false, date: 1.week.ago.to_date) }

    let(:athlete_in_results) { create(:athlete) }
    let(:athlete_missing) { create(:athlete) }
    let(:athlete_other_role) { create(:athlete) }
    let(:athlete_unpublished) { create(:athlete) }
    let(:incorrect) { create(:volunteer, activity: ok_activity, athlete: athlete_missing, role: :event_closer) }

    before do
      create(:result, activity: ok_activity, athlete: athlete_in_results)
      create(:volunteer, activity: ok_activity, athlete: athlete_in_results, role: :pacemaker)
      create(:volunteer, activity: ok_activity, athlete: athlete_other_role, role: :timer)

      create(:volunteer, activity: no_results_activity, athlete: create(:athlete), role: :attendant)
      create(:result, activity: unpublished_activity, athlete: athlete_unpublished)
      create(:volunteer, activity: unpublished_activity, athlete: athlete_unpublished, role: :pacemaker)
    end

    it 'returns volunteers on running positions that are missing from results' do
      expect(described_class.incorrect_on_running_positions).to contain_exactly(incorrect)
    end
  end

  describe 'validation' do
    subject(:volunteer) { described_class.new }

    it { is_expected.not_to be_valid }

    it 'strips comment before validation' do
      volunteer.comment = ' test '
      expect { volunteer.valid? }.to change(volunteer, :comment).to('test')
    end

    it 'valid with activity, athlete and role' do
      volunteer.role = 0
      volunteer.athlete = build :athlete
      volunteer.activity = build :activity
      expect(volunteer).to be_valid
    end
  end
end
