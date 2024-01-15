# frozen_string_literal: true

RSpec.describe HomeBadgeAwardingJob do
  fixtures :badges

  let(:home_event) { create(:event) }
  let(:athlete) { create(:athlete, event: home_event) }

  it 'performs immediately' do
    create(:result, athlete: athlete, activity_params: { event: home_event })
    expect { described_class.perform_later(athlete.id) }.to have_enqueued_job.on_queue('low').at(:no_wait)
  end

  context 'when conditions are met' do
    before do
      25.times do |idx|
        activity = create(:activity, event: home_event, date: idx.week.ago)
        create(:result, athlete:, activity:)
        create(:volunteer, athlete:, activity:)
      end

      described_class.perform_now(athlete.id)
    end

    it 'creates home event trophies' do
      expect(athlete.trophies.find_by(badge_id: 39).date).to eq(Date.current)
      expect(athlete.trophies.find_by(badge_id: 42).date).to eq(Date.current)
    end
  end
end
