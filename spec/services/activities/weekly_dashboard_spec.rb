# frozen_string_literal: true

RSpec.describe Activities::WeeklyDashboard, type: :service do
  subject(:dashboard_chart) do
    described_class.call(country_events: Event.in_country(:ru), chart: chart_name)
  end

  let(:event) { create(:event, country_id: 1) }
  let(:activity) { create(:activity, event: event, date: Date.current) }

  describe '#call' do
    context 'with participants chart' do
      let(:chart_name) { 'participants' }

      before do
        create(:result, activity: activity, personal_best: true, first_run: true)
        create(:result, activity: activity, personal_best: true, first_run: false)
        create(:result, activity: activity, personal_best: false, first_run: false)
      end

      it 'builds series without empty slices' do
        expect(dashboard_chart).to have_attributes(key: 'participants', id: 'participants-chart', total: 3)
        expect(dashboard_chart.series.size).to eq(dashboard_chart.labels.size)
        expect(dashboard_chart.series.sum).to eq(3)
        expect(dashboard_chart).not_to be_empty
      end
    end

    context 'with gender chart' do
      let(:chart_name) { 'gender' }

      before do
        create(:result, activity: activity, athlete: create(:athlete, gender: 'male'))
        create(:result, activity: activity, athlete: create(:athlete, gender: 'female'))
      end

      it 'groups results by gender' do
        expect(dashboard_chart.total).to eq(2)
        expect(dashboard_chart.labels).to include(
          I18n.t('activities.dashboard.male'),
          I18n.t('activities.dashboard.female'),
        )
      end
    end

    context 'with volunteers chart' do
      let(:chart_name) { 'volunteers' }

      before { create(:volunteer, activity:) }

      it 'returns volunteer totals' do
        expect(dashboard_chart).to have_attributes(key: 'volunteers', total: 1)
        expect(dashboard_chart).not_to be_empty
      end
    end

    context 'when there is no weekly data' do
      let(:chart_name) { 'participants' }

      it 'returns an empty chart' do
        expect(dashboard_chart).to be_empty
        expect(dashboard_chart.series).to be_empty
      end
    end

    context 'with an unknown chart' do
      let(:chart_name) { 'unknown' }

      it 'raises' do
        expect { dashboard_chart }.to raise_error(ArgumentError, /Unknown dashboard chart/)
      end
    end
  end
end
