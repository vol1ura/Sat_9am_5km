RSpec.describe FunrunAwardingJob do
  let(:activity) { create(:activity) }
  let(:athlete) { create(:athlete) }
  let(:volunteer) { create(:athlete) }
  let(:badge) { create(:badge) }

  before do
    create(:result, activity:, athlete:)
    create(:volunteer, activity: activity, athlete: volunteer)
  end

  it 'awards athlete by badge' do
    expect do
      described_class.perform_now(activity.id, badge.id)
    end
      .to change { athlete.trophies.exists?(badge:) }.from(false).to(true)
      .and change { volunteer.trophies.exists?(badge:) }.from(false).to(true)
  end

  context 'when athlete already has this badge' do
    before { create(:trophy, badge:, athlete:) }

    it 'does not award athlete' do
      expect do
        described_class.perform_now(activity.id, badge.id)
      end
        .not_to(change { athlete.reload.trophies.count })
    end
  end
end
