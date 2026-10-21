# frozen_string_literal: true

RSpec.describe '/athletes/:athlete_id/statistics' do
  let(:athlete) { create(:athlete) }
  let(:turbo_frame_headers) { { 'Turbo-Frame' => 'statistics' } }

  shared_examples 'athlete statistics endpoint' do |path_helper|
    it 'renders a successful response for turbo frame' do
      get public_send(path_helper, athlete_id: athlete.id), headers: turbo_frame_headers

      expect(response).to be_successful
    end

    it 'redirects HTML requests to the athlete profile' do
      get public_send(path_helper, athlete_id: athlete.id)

      expect(response).to redirect_to(athlete_url(athlete))
    end
  end

  describe 'GET /personal_bests' do
    it_behaves_like 'athlete statistics endpoint', :personal_bests_athlete_statistics_url
  end

  describe 'GET /total_results' do
    it_behaves_like 'athlete statistics endpoint', :total_results_athlete_statistics_url
  end

  describe 'GET /total_events' do
    it_behaves_like 'athlete statistics endpoint', :total_events_athlete_statistics_url

    context 'with finishes and volunteering' do
      let(:event) { create(:event) }

      before do
        create(:result, athlete: athlete, activity_params: { event: })
        create(:volunteer, athlete: athlete, activity_params: { event: })

        get total_events_athlete_statistics_url(athlete_id: athlete.id), headers: turbo_frame_headers
      end

      it 'links event names to event pages' do
        event_href = event_path(event.code_name)

        expect(response.body).to include(event.name)
        expect(response.body.scan(%(href="#{event_href}")).size).to eq(2)
      end
    end
  end

  describe 'GET /total_trophies' do
    it_behaves_like 'athlete statistics endpoint', :total_trophies_athlete_statistics_url
  end

  describe 'GET /goals' do
    it_behaves_like 'athlete statistics endpoint', :goals_athlete_statistics_url
  end

  describe 'GET /followers' do
    it_behaves_like 'athlete statistics endpoint', :followers_athlete_statistics_url
  end

  describe 'GET /friends' do
    it_behaves_like 'athlete statistics endpoint', :friends_athlete_statistics_url
  end

  describe 'GET /volunteering_chart' do
    it_behaves_like 'athlete statistics endpoint', :volunteering_chart_athlete_statistics_url
  end
end
