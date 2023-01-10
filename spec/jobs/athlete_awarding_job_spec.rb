RSpec.describe AthleteAwardingJob do
  fixtures :badges

  let(:athlete) { create(:athlete) }

  context 'with participants badges' do
    let(:event) { create(:event) }
    let(:activity) { create(:activity, date: Time.zone.today, event: event) }

    before do
      24.times do |idx|
        activity = create(:activity, event: event, date: idx.next.week.ago)
        create(:result, athlete: athlete, activity: activity)
        create(:volunteer, athlete: athlete, activity: activity)
      end
    end

    it 'performs immediately' do
      expect { described_class.perform_later(activity.id) }.to have_enqueued_job.on_queue('default').at(:no_wait)
    end

    it 'creates new trophies' do
      create(:result, activity: activity, athlete: athlete)
      create(:volunteer, activity: activity, athlete: athlete)
      expect do
        described_class.perform_now(activity.id)
      end.to change(athlete.trophies, :count).by(3)
    end
  end

  context 'with tourist and record badges' do
    it 'creates runner badge' do
      create_list(:result, 5, athlete: athlete)
      last_activity_id = athlete.results.joins(:activity).order('activities.date').last.activity_id
      expect do
        described_class.perform_now(last_activity_id)
      end.to change(athlete.trophies, :count).by(2)
    end

    it 'creates volunteer badge' do
      5.times do |i|
        activity = create(:activity, date: i.weeks.ago, published: true)
        create(:volunteer, athlete: athlete, activity: activity)
      end
      last_activity_id = athlete.volunteering.reorder('activity.date').last.activity_id
      expect do
        described_class.perform_now(last_activity_id)
      end.to change(athlete.trophies, :count).by(1)
    end
  end
end
