# frozen_string_literal: true

RSpec.describe BreakingTimeAwardingJob do
  let(:athlete) { create(:athlete) }
  let(:activity) { create(:activity, date: Date.yesterday) }

  before do
    [16, 18, 20].map { |x| x * 60 }.each do |threshold|
      create(:badge, info: { gender: 'male', sec: threshold }, kind: :breaking)
    end
  end

  it 'performs immediately' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('default').at(:no_wait)
  end

  it 'expires old trophy' do
    create(:trophy, date: 4.months.ago, athlete: athlete, badge_id: Badge.breaking_kind.ids.sample)

    expect { described_class.perform_now }.to change(athlete.trophies, :count).by(-1)
  end

  it 'updates trophy date' do
    badge = Badge.breaking_kind.take!
    trophy = create(:trophy, date: 2.months.ago, athlete: athlete, badge: badge)
    create(:result, activity: activity, athlete: athlete, total_time: (badge.info['sec'] - 1))

    expect { described_class.perform_now }.not_to change(athlete.trophies, :count)
    expect(trophy.reload.date).to eq activity.date
  end

  it 'adds new trophy' do
    create(:result, activity: activity, athlete: athlete, total_time: (17 * 60) + 59)

    expect { described_class.perform_now(activity.id) }.to change(athlete.trophies, :count).by(1)
  end
end
