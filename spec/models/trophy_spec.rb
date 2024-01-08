# frozen_string_literal: true

RSpec.describe Trophy do
  let(:badge) { create(:badge) }
  let(:some_athlete) { create(:athlete) }

  it { is_expected.not_to be_valid }

  it 'valid with badge and uniq athlete' do
    other_athlete = create(:athlete)
    create(:trophy, badge: badge, athlete: other_athlete)
    trophy = build(:trophy, badge: badge, athlete: some_athlete)
    expect(trophy).to be_valid
  end

  it 'invalid with badge and same athlete' do
    create(:trophy, badge: badge, athlete: some_athlete)
    trophy = build(:trophy, badge: badge, athlete: some_athlete)
    expect(trophy).not_to be_valid
  end
end
