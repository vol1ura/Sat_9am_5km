# frozen_string_literal: true

RSpec.describe '/activities' do
  describe 'GET /index' do
    it 'renders a successful response' do
      create_list(:activity, 3)
      get activities_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    let(:activity) { create(:activity) }
    let!(:result) { create(:result, activity:) }
    let!(:volunteer) { create(:volunteer, activity:) }
    let(:athlete_fields) { %i[id name parkrun_code gender] }

    it 'renders a successful response' do
      create(:participating_badge)
      get activity_url(activity)

      expect(response).to be_successful
    end

    it 'renders json' do
      get activity_url(activity, format: :json)

      expect(response.parsed_body.dig('results', 0)).to eq(
        'total_time' => result.time_string,
        'position' => result.position,
        'athlete' => result.athlete.as_json(only: athlete_fields),
      )
      expect(response.parsed_body.dig('volunteers', 0)).to eq(
        'role' => volunteer.role,
        'athlete' => volunteer.athlete.as_json(only: athlete_fields),
      )
    end
  end

  describe 'GET /dashboard/:chart' do
    before { create_list(:activity, 3, date: Date.current) }

    %w[participants gender volunteers].each do |chart|
      it "renders #{chart} chart" do
        get dashboard_chart_activities_url(chart), headers: { host: 'test.ru' }

        expect(response).to be_successful
      end
    end
  end
end
