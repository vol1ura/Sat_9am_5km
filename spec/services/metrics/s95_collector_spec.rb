# frozen_string_literal: true

RSpec.describe Metrics::S95Collector do
  describe '.call' do
    subject(:result) { described_class.call }

    let(:event) { create(:event, active: true) }
    let(:activity_date) { Date.current }
    let(:activity) { create(:activity, event: event, published: true, date: activity_date) }

    before do
      athlete = create(:athlete, event: event, gender: 'male')
      user_athlete = create(:athlete, :with_user, event: event, gender: 'female')
      going_athlete = create(:athlete, going_to_event: event)

      create(:result, activity: activity, athlete: athlete, first_run: true, personal_best: false)
      create(:result, activity: activity, athlete: user_athlete, first_run: false, personal_best: true)
      create(:volunteer, activity: activity, athlete: going_athlete, role: :director)
    end

    it 'returns event and activity totals' do
      expect(result).to include(%(s95_events_total{country="#{event.country.code}",active="true"} 1))
      expect(result).to include(
        %(s95_activities_total{event="#{event.code_name}",country="#{event.country.code}",published="true"} 1),
      )
    end

    it 'returns recent activity result counters' do
      expect(result).to include(
        %(s95_activity_results_total{event="#{event.code_name}",activity_date="#{activity_date}"} 2),
      )
      expect(result).to include(
        %(s95_activity_first_runs_total{event="#{event.code_name}",activity_date="#{activity_date}"} 1),
      )
      expect(result).to include(
        %(s95_activity_personal_bests_total{event="#{event.code_name}",activity_date="#{activity_date}"} 1),
      )
    end

    it 'returns recent volunteer counters' do
      expect(result).to include(
        %(s95_activity_volunteers_total{event="#{event.code_name}",activity_date="#{activity_date}"} 1),
      )
      expect(result).to include(
        %(s95_volunteers_by_role_total{event="#{event.code_name}",activity_date="#{activity_date}",role="director"} 1),
      )
    end

    it 'returns Prometheus metric lines' do
      expect(result).to match(/s95_.*\{.*\}\s+\d+/)
    end

    it 'does not expose expensive derived metrics' do
      expensive_metrics = %w[
        active_community_total activity_best_time_seconds activity_median_time_seconds athletes_total
        location_health_score volunteer_bus_factor
      ]

      expect(result).not_to match(/s95_(#{expensive_metrics.join('|')})/)
    end
  end
end
