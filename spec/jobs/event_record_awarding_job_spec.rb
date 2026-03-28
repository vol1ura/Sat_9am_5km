# frozen_string_literal: true

RSpec.describe EventRecordAwardingJob do
  let(:event) { create(:event) }
  let!(:record_badge) { create(:badge, kind: :record, info: { gender: 'male' }) }

  describe '#perform' do
    context 'when no record trophies exist' do
      let(:athlete) { create(:athlete) }

      it 'creates trophy for best result' do
        result = create(:result, athlete: athlete, total_time: 19 * 60, activity_params: { event: })

        expect { described_class.perform_now(event.id) }.to change(Trophy, :count).by(1)

        trophy = Trophy.find_by(badge: record_badge, athlete_id: athlete.id)
        expect(trophy.data).to contain_exactly({ 'event_id' => event.id, 'result_id' => result.id })
      end
    end

    context 'when new result beats existing record' do
      let(:old_athlete) { create(:athlete) }
      let(:old_result) { create(:result, athlete: old_athlete, total_time: 20 * 60, activity_params: { event: }) }
      let!(:trophy) do
        create(
          :trophy,
          badge: record_badge,
          athlete: old_athlete,
          info: { data: [{ 'event_id' => event.id, 'result_id' => old_result.id }] },
        )
      end
      let(:new_athlete) { create(:athlete) }
      let!(:new_result) { create(:result, athlete: new_athlete, total_time: (19 * 60) + 59, activity_params: { event: }) }

      it 'removes old trophy and awards new athlete' do
        described_class.perform_now(event.id)

        expect(Trophy).not_to exist(id: trophy.id)
        new_trophy = Trophy.find_by(badge: record_badge, athlete_id: new_athlete.id)
        expect(new_trophy.data).to contain_exactly(
          hash_including('event_id' => event.id, 'result_id' => new_result.id),
        )
      end
    end

    context 'when athlete updates own best result' do
      let(:athlete) { create(:athlete) }
      let(:old_result) { create(:result, athlete: athlete, total_time: 20 * 60, activity_params: { event: }) }
      let!(:trophy) do
        create(
          :trophy,
          badge: record_badge,
          athlete: athlete,
          info: { data: [{ 'event_id' => event.id, 'result_id' => old_result.id }] },
        )
      end
      let!(:new_result) { create(:result, athlete: athlete, total_time: 19 * 60, activity_params: { event: }) }

      it 'updates trophy data with new result' do
        described_class.perform_now(event.id)

        trophy.reload
        expect(trophy.athlete_id).to eq athlete.id
        expect(trophy.data).to contain_exactly(
          hash_including('result_id' => new_result.id),
        )
      end
    end

    context 'with broken result_id in trophy' do
      let(:stale_athlete) { create(:athlete) }
      let!(:trophy) do
        create(
          :trophy,
          badge: record_badge,
          athlete: stale_athlete,
          info: { data: [{ 'event_id' => event.id, 'result_id' => 0 }] },
        )
      end
      let(:athlete) { create(:athlete) }

      it 'corrects data to actual record holder' do
        create(:result, athlete: athlete, total_time: 19 * 60, activity_params: { event: })

        described_class.perform_now(event.id)

        expect(Trophy).not_to exist(id: trophy.id)
        expect(Trophy).to exist(badge: record_badge, athlete_id: athlete.id)
      end
    end

    context 'when trophy is awarded to wrong athlete' do
      let(:wrong_athlete) { create(:athlete) }
      let(:correct_athlete) { create(:athlete) }
      let!(:result) { create(:result, athlete: correct_athlete, total_time: 18 * 60, activity_params: { event: }) }
      let!(:wrong_trophy) do
        create(
          :trophy,
          badge: record_badge,
          athlete: wrong_athlete,
          info: { data: [{ 'event_id' => event.id, 'result_id' => result.id }] },
        )
      end

      it 'reassigns record to correct athlete' do
        described_class.perform_now(event.id)

        expect(Trophy).not_to exist(id: wrong_trophy.id)
        expect(Trophy).to exist(badge: record_badge, athlete_id: correct_athlete.id)
      end
    end

    context 'with idempotent execution' do
      it 'produces the same result on repeated runs' do
        create(:result, athlete: create(:athlete), total_time: 19 * 60, activity_params: { event: })

        described_class.perform_now(event.id)
        snapshot = Trophy.where(badge: record_badge).order(:id).pluck(:athlete_id, :info)

        expect { described_class.perform_now(event.id) }.not_to change(Trophy.where(badge: record_badge), :count)
        expect(Trophy.where(badge: record_badge).order(:id).pluck(:athlete_id, :info)).to eq snapshot
      end
    end

    context 'when multiple athletes tie in the same activity' do
      let(:athletes) { create_list(:athlete, 3) }

      it 'awards trophy to each record holder' do
        athletes.each { |athlete| create(:result, athlete: athlete, total_time: 18 * 60, activity_params: { event: }) }

        expect { described_class.perform_now(event.id) }.to change(Trophy, :count).by(3)

        athletes.each do |athlete|
          expect(Trophy).to exist(badge: record_badge, athlete_id: athlete.id)
        end
      end
    end

    context 'when athletes tie across different activities' do
      let(:first_athlete) { create(:athlete) }
      let(:second_athlete) { create(:athlete) }

      it 'awards trophy to each record holder' do
        create(:result, activity_params: { event: event, date: 2.weeks.ago }, athlete: first_athlete, total_time: 18 * 60)
        create(:result, activity_params: { event: event, date: 1.week.ago }, athlete: second_athlete, total_time: 18 * 60)

        expect { described_class.perform_now(event.id) }.to change(Trophy, :count).by(2)
        expect(Trophy).to exist(badge: record_badge, athlete_id: first_athlete.id)
        expect(Trophy).to exist(badge: record_badge, athlete_id: second_athlete.id)
      end
    end

    context 'when athlete has same best time in multiple activities' do
      let(:athlete) { create(:athlete) }
      let!(:best_position_result) do
        create(
          :result,
          activity_params: { event: event, date: 1.week.ago },
          athlete: athlete,
          total_time: 18 * 60,
          position: 1,
        )
      end

      before do
        create(
          :result,
          activity_params: { event: event, date: 2.weeks.ago },
          athlete: athlete,
          total_time: 18 * 60,
          position: 3,
        )
      end

      it 'stores result with best position' do
        described_class.perform_now(event.id)

        trophy = Trophy.find_by(badge: record_badge, athlete_id: athlete.id)
        expect(trophy.data).to contain_exactly(
          hash_including('result_id' => best_position_result.id),
        )
      end
    end

    context 'when best result is in an older activity' do
      let(:record_holder) { create(:athlete) }
      let(:recent_athlete) { create(:athlete) }

      it 'awards trophy regardless of activity date' do
        create(:result, activity_params: { event: event, date: 1.year.ago }, athlete: record_holder, total_time: 17 * 60)
        create(:result, activity_params: { event: event, date: Date.current }, athlete: recent_athlete, total_time: 18 * 60)

        described_class.perform_now(event.id)

        expect(Trophy).to exist(badge: record_badge, athlete_id: record_holder.id)
        expect(Trophy).not_to exist(badge: record_badge, athlete_id: recent_athlete.id)
      end
    end

    context 'when trophy has records for multiple events' do
      let(:other_event) { create(:event) }
      let(:athlete) { create(:athlete) }
      let(:new_athlete) { create(:athlete) }
      let(:result) { create(:result, athlete: athlete, total_time: 20 * 60, activity_params: { event: }) }
      let(:other_result) do
        create(:result, athlete: athlete, total_time: 19 * 60, activity_params: { event: other_event })
      end
      let!(:trophy) do
        create(
          :trophy,
          badge: record_badge,
          athlete: athlete,
          info: {
            data: [
              { 'event_id' => event.id, 'result_id' => result.id },
              { 'event_id' => other_event.id, 'result_id' => other_result.id },
            ],
          },
        )
      end

      it 'preserves records for other events' do
        create(:result, athlete: new_athlete, total_time: 18 * 60, activity_params: { event: })

        described_class.perform_now(event.id)

        trophy.reload
        expect(trophy.data).to contain_exactly(
          hash_including('event_id' => other_event.id, 'result_id' => other_result.id),
        )
        expect(Trophy).to exist(badge: record_badge, athlete_id: new_athlete.id)
      end
    end

    context 'with no published results for event' do
      let(:athlete) { create(:athlete) }
      let!(:trophy) do
        create(
          :trophy,
          badge: record_badge,
          athlete: athlete,
          info: { data: [{ 'event_id' => event.id, 'result_id' => 1 }] },
        )
      end

      it 'removes stale trophy entries' do
        described_class.perform_now(event.id)

        expect(Trophy).not_to exist(id: trophy.id)
      end
    end
  end
end
