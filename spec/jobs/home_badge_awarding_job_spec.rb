# frozen_string_literal: true

RSpec.describe HomeBadgeAwardingJob do
  let(:home_event) { create(:event) }
  let(:athlete) { create(:athlete, event: home_event) }
  let!(:athlete_home_kind_badge_25) { create(:participating_badge, kind: :home_participating) }
  let!(:volunteer_home_kind_badge_25) { create(:participating_badge, kind: :home_participating, type: 'volunteer') }

  context 'when conditions are met' do
    before do
      create(:participating_badge, kind: :home_participating, threshold: 50)
      create(:participating_badge, kind: :home_participating, type: 'volunteer', threshold: 50)

      25.times do |idx|
        activity = create(:activity, event: home_event, date: idx.week.ago)
        create(:result, athlete:, activity:)
        create(:volunteer, athlete:, activity:)
      end

      described_class.perform_now(athlete.id)
    end

    it 'creates home event trophies' do
      expect(athlete.trophies.find_by(badge: athlete_home_kind_badge_25).date).to eq(Date.current)
      expect(athlete.trophies.find_by(badge: volunteer_home_kind_badge_25).date).to eq(Date.current)
    end
  end
end
