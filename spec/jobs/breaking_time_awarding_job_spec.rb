RSpec.describe BreakingTimeAwardingJob do
  fixtures :badges

  let(:athlete) { create(:athlete) }
  let(:activity) { create(:activity, date: Date.yesterday) }

  it 'performs immediately' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('default').at(:no_wait)
  end

  it 'expires old trophy' do
    create(:trophy, date: 4.months.ago, athlete: athlete, badge_id: [13, 14, 15].sample)
    expect { described_class.perform_now }.to change(athlete.trophies, :count).by(-1)
  end

  it 'updates trophy date' do
    trophy = create(:trophy, date: 2.months.ago, athlete: athlete, badge_id: 15)
    create(:result, activity: activity, athlete: athlete, total_time: Result.total_time(19, 59))
    expect { described_class.perform_now }.not_to change(athlete.trophies, :count)
    expect(trophy.reload.date).to eq activity.date
  end

  it 'adds new trophy' do
    create(:result, activity: activity, athlete: athlete, total_time: Result.total_time(17, 59))
    expect { described_class.perform_now }.to change(athlete.trophies, :count).by(1)
  end
end
