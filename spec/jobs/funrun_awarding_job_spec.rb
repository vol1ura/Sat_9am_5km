RSpec.describe FunrunAwardingJob do
  let(:activity) { create(:activity) }
  let(:athlete) { create(:athlete) }
  let(:volunteer) { create(:athlete) }
  let(:badge) { create(:badge, kind: :funrun) }

  before do
    create(:result, activity:, athlete:)
    create(:volunteer, activity: activity, athlete: volunteer)
  end

  it 'awards athlete by badge' do
    expect do
      described_class.perform_now(activity.id, badge.id)
    end
      .to change(athlete.trophies, :count).by(1)
      .and change(volunteer.trophies, :count).by(1)
  end
end
