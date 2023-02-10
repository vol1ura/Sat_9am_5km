RSpec.describe AthleteAwardingJob do
  fixtures :badges

  let(:athlete) { create(:athlete) }

  context 'with participants badges' do
    let(:event) { create(:event) }
    let(:activity) { create(:activity, date: Time.zone.today, event: event) }

    before do
      24.times do |idx|
        activity = create(:activity, event: event, date: idx.next.week.ago)
        create(:result, athlete: athlete, activity: activity, total_time: Time.zone.local(2000, 1, 1, 0, 19, idx))
        create(:volunteer, athlete: athlete, activity: activity)
      end
    end

    it 'performs immediately' do
      expect { described_class.perform_later(activity.id) }.to have_enqueued_job.on_queue('default').at(:no_wait)
    end

    it 'creates new trophies' do
      create(:result, activity: activity, athlete: athlete, total_time: Time.zone.local(2000, 1, 1, 0, 18, 30))
      create(:volunteer, activity: activity, athlete: athlete)
      expect do
        described_class.perform_now(activity.id)
      end.to change(athlete.trophies, :count).by(4)
        .and change(Trophy.where(badge_id: 7), :count).by(1)
        .and change(Trophy.where(badge_id: 10), :count).by(1)
        .and change(Trophy.where(badge_id: 22), :count).by(1)
        .and change(Trophy.where(badge_id: 25), :count).by(1)
    end
  end

  context 'with tourist and record badges' do
    it 'creates runner badge' do
      5.times do |idx|
        total_time = Time.zone.local(2000, 1, 1, 0, 19, 10 - idx)
        create(:result, athlete: athlete, total_time: total_time, activity_params: { date: idx.weeks.ago })
      end
      last_activity_id = athlete.results.joins(:activity).order('activities.date').last.activity_id
      expect do
        described_class.perform_now(last_activity_id)
      end.to change(athlete.reload.trophies, :count).by(2)
        .and change(Trophy.where(badge_id: 20), :count).by(1)
        .and change(Trophy.where(badge_id: 22), :count).by(1)
    end

    it 'creates volunteer badge' do
      5.times do |idx|
        create(:volunteer, athlete: athlete, activity_params: { date: idx.weeks.ago })
      end
      last_activity_id = athlete.volunteering.reorder('activity.date').last.activity_id
      expect do
        described_class.perform_now(last_activity_id)
      end.to change(athlete.trophies, :count).by(1)
    end
  end
end
