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

  describe '.incorrect_on_non_running_positions' do
    let(:date) { 1.week.ago.to_date }
    let(:volunteer_activity) { create(:activity, published: true, date: date) }
    let(:result_activity) { create(:activity, published: true, date: date) }
    let(:incorrect) { create(:volunteer, activity: volunteer_activity, athlete: create(:athlete), role: :marshal) }
    let(:same_activity_volunteer) do
      create(:volunteer, activity: volunteer_activity, athlete: create(:athlete), role: :timer)
    end

    before do
      create(:result, activity: result_activity, athlete: incorrect.athlete)
      create(:result, activity: volunteer_activity, athlete: same_activity_volunteer.athlete)

      other_date_athlete = create(:athlete)
      create(:volunteer, activity: volunteer_activity, athlete: other_date_athlete, role: :bike_leader)
      create(:result, activity: create(:activity, published: true, date: date - 1.week), athlete: other_date_athlete)

      unpublished_athlete = create(:athlete)
      create(:volunteer, activity: volunteer_activity, athlete: unpublished_athlete, role: :marshal)
      create(:result, activity: create(:activity, published: false, date: date), athlete: unpublished_athlete)

      running_role_athlete = create(:athlete)
      create(:volunteer, activity: volunteer_activity, athlete: running_role_athlete, role: :pacemaker)
      create(:result, activity: result_activity, athlete: running_role_athlete)
    end

    it 'returns volunteers on non-running positions with a result on the same date' do
      expect(described_class.incorrect_on_non_running_positions).to contain_exactly(incorrect, same_activity_volunteer)
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
