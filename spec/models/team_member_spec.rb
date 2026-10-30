# frozen_string_literal: true

RSpec.describe TeamMember do
  it { is_expected.not_to be_valid }

  it 'valid with athlete, role, rank and photo' do
    expect(build(:team_member)).to be_valid
  end

  it 'has rank 1 by default' do
    expect(described_class.new.rank).to eq 1
  end

  it 'invalid without photo' do
    member = build(:team_member)
    member.photo.detach
    expect(member).not_to be_valid
  end

  it 'invalid with non-positive rank' do
    expect(build(:team_member, rank: 0)).not_to be_valid
  end

  it 'invalid with duplicated athlete' do
    member = create(:team_member)
    expect(build(:team_member, athlete: member.athlete)).not_to be_valid
  end
end
