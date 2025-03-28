# frozen_string_literal: true

RSpec.describe AthletesAwardingJob do
  let(:athlete) { create(:athlete) }
  let!(:record_badge) { create(:badge, kind: :record, info: { male: true }) }

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
        create(:result, athlete: athlete, activity: activity, total_time: Result.total_time(19, idx))
        create(:volunteer, athlete:, activity:)
      end
      create(:result, activity: activity, athlete: athlete, total_time: Result.total_time(18, 30))
      create(:volunteer, activity:, athlete:)
    end

    it 'creates new trophies' do
      expect do
        described_class.perform_now(activity.id)
      end.to change(athlete.trophies, :count).by(4)
      expect(athlete.trophies.joins(:badge).pluck(:kind)).to contain_exactly(
        'record', 'rage', 'participating', 'participating',
      )
      expect(FunrunAwardingJob).to have_received(:perform_later).once
    end
  end

  context 'with record badge' do
    let(:event) { create(:event) }
    let(:old_best_result) { create(:result, athlete: old_best_result_athlete, total_time: Result.total_time(20, 0)) }
    let(:old_best_result_athlete) { create(:athlete) }
    let!(:trophy) do
      create(
        :trophy,
        badge: record_badge,
        athlete: old_best_result.athlete,
        info: { data: [{ event_id: event.id, result_id: trophy_result_id }] },
      )
    end
    let(:trophy_result_id) { old_best_result.id }

    before do
      activity = create(:activity, date: Time.zone.today, event: event)
      create(:result, activity: activity, athlete: athlete, total_time: Result.total_time(19, 59))

      described_class.perform_now(activity.id)
    end

    shared_examples 'awards athlete' do
      specify do
        expect(athlete.trophies.joins(:badge).pluck(:kind)).to contain_exactly('record')
        expect(trophy.reload.athlete_id).to eq athlete.id
      end
    end

    it 'awards athlete' do
      expect(athlete.trophies.joins(:badge).pluck(:kind)).to contain_exactly('record')
      expect(Trophy).not_to exist(id: trophy.id)
    end

    context 'when athlete updates own best result' do
      let(:old_best_result_athlete) { athlete }

      it_behaves_like 'awards athlete'
    end

    context 'with broken result_id in trophy' do
      let(:trophy_result_id) { 0 }

      it_behaves_like 'awards athlete'
    end
  end

  context 'with tourist and record badges' do
    it 'creates runner badge' do
      5.times do |idx|
        total_time = Result.total_time(19, 10 - idx)
        create(:result, athlete: athlete, total_time: total_time, activity_params: { date: idx.weeks.ago })
      end

      expect do
        described_class.perform_now(
          athlete.results.joins(:activity).order('activities.date').last.activity_id,
        )
      end.to change(athlete.trophies, :count).by(2)
      expect(athlete.trophies.joins(:badge).pluck(:kind)).to contain_exactly('tourist', 'record')
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
