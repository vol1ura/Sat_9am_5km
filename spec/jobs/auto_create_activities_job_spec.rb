# frozen_string_literal: true

RSpec.describe AutoCreateActivitiesJob do
  include ActiveSupport::Testing::TimeHelpers

  it 'enqueues on low queue' do
    expect { described_class.perform_later }.to have_enqueued_job.on_queue('low')
  end

  describe '#perform' do
    let!(:event) { create(:event, active: true, auto_create_activities: true) }
    let!(:inactive_event) { create(:event, active: false, auto_create_activities: true) }
    let!(:event_without_flag) { create(:event, active: true, auto_create_activities: false) }
    let!(:existing_activity) { create(:activity, event: event, date: Date.new(2026, 5, 2)) }

    it 'creates unpublished activities for the next four Saturdays', :aggregate_failures do
      travel_to Date.new(2026, 4, 25) do
        expect { described_class.perform_now }.to change { event.activities.count }.by(3)
      end

      expect(event.activities.order(:date).pluck(:date)).to eq(
        (0...4).map { |k| Date.new(2026, 5, 2).advance(weeks: k) },
      )
      expect(event.activities.where.not(id: existing_activity).pluck(:published).uniq).to eq [false]
      expect(existing_activity.reload.published).to be true
      expect(inactive_event.activities).to be_empty
      expect(event_without_flag.activities).to be_empty
    end
  end
end
