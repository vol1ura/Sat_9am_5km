RSpec.describe HomeBadgeAwardingJob do
  fixtures :badges

  let(:home_event) { create(:event) }
  let(:athlete) { create(:athlete, event: home_event) }

  before do
    25.times do |idx|
      activity = create(:activity, event: home_event, date: idx.week.ago)
      create(:result, athlete:, activity:)
      create(:volunteer, athlete:, activity:)
    end
  end

  it 'performs immediately' do
    expect { described_class.perform_later(athlete.id) }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  it 'creates home event trophies' do
    expect do
      described_class.perform_now(athlete.id)
    end.to change { athlete.trophies.exists?(badge_id: 39) }.to(true)
      .and change { athlete.trophies.exists?(badge_id: 42) }.to(true)
  end
end
