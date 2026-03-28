# frozen_string_literal: true

RSpec.describe AthletesAwardingJob do
  let(:athlete) { create(:athlete) }

  before do
    create(:badge, kind: :rage)
    create(:badge, kind: :tourist, info: { threshold: 5, type: 'result' })
    create(:badge, kind: :tourist, info: { threshold: 5, type: 'volunteer' })
  end

  context 'with participants badges' do
    let(:event) { create(:event) }
    let(:activity) { create(:activity, date: Time.zone.today, event: event) }
    let(:jubilee_badge) { create(:participating_badge, threshold: 25, kind: :jubilee_participating, type: nil) }

    before do
      [25, 50, 100].each do |threshold|
        create(:participating_badge, threshold:)
        create(:participating_badge, threshold: threshold, type: 'volunteer')
      end
      allow(FunrunAwardingJob).to receive(:perform_later).with(activity.id, jubilee_badge.id)

      24.times do |idx|
        activity = create(:activity, event: event, date: idx.next.week.ago)
        create(:result, athlete: athlete, activity: activity, total_time: (19 * 60) + idx)
        create(:volunteer, athlete:, activity:)
      end
      create(:result, activity: activity, athlete: athlete, total_time: (18 * 60) + 30)
      create(:volunteer, activity:, athlete:)
    end

    it 'creates new trophies' do
      expect do
        described_class.perform_now(activity.id)
      end.to change(athlete.trophies, :count).by(3)
      expect(athlete.trophies.joins(:badge).pluck(:kind)).to contain_exactly(
        'rage', 'participating', 'participating',
      )
      expect(FunrunAwardingJob).to have_received(:perform_later).once
    end
  end

  context 'with tourist badge' do
    it 'creates runner badge' do
      5.times do |idx|
        total_time = (19 * 60) + (10 - idx)
        create(:result, athlete: athlete, total_time: total_time, activity_params: { date: idx.weeks.ago })
      end

      expect do
        described_class.perform_now(
          athlete.results.joins(:activity).order('activities.date').last.activity_id,
        )
      end.to change(athlete.trophies, :count).by(1)
      expect(athlete.trophies.joins(:badge).pluck(:kind)).to eq(['tourist'])
    end

    it 'creates volunteer badge' do
      5.times do |idx|
        create(:volunteer, athlete: athlete, activity_params: { date: idx.weeks.ago })
      end

      expect do
        described_class.perform_now(
          athlete.volunteering.reorder('activity.date').last.activity_id,
        )
      end.to change(athlete.trophies, :count).by(1)
    end
  end
end
