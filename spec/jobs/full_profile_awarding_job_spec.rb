# frozen_string_literal: true

RSpec.describe FullProfileAwardingJob do
  let!(:athlete_with_full_profile) { create(:athlete, event: event, user: create(:user, with_avatar: true)) }
  let(:athlete_without_full_profile) { create(:athlete, event:) }
  let(:event) { create(:event) }
  let(:full_profile_badge) { create(:badge, kind: :full_profile) }

  before { create(:trophy, badge: full_profile_badge, athlete: athlete_without_full_profile) }

  it 'awards and expires trophies' do
    described_class.perform_now
    expect(athlete_with_full_profile.trophies).to exist(badge: full_profile_badge)
    expect(athlete_without_full_profile.trophies).to be_empty
  end
end
