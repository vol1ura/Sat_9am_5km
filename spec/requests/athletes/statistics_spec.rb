# frozen_string_literal: true

RSpec.describe '/athletes/:athlete_id/statistics' do
  let(:athlete) { create(:athlete) }

  describe 'GET /personal_bests' do
    before do
      get personal_bests_athlete_statistics_url(athlete_id: athlete.id)
    end

    it { expect(response).to be_successful }
  end

  describe 'GET /total_results' do
    it 'renders a successful response' do
      get total_results_athlete_statistics_url(athlete_id: athlete.id)
      expect(response).to be_successful
    end
  end

  describe 'GET /total_events' do
    it 'renders a successful response' do
      get total_events_athlete_statistics_url(athlete_id: athlete.id)
      expect(response).to be_successful
    end

    context 'with finishes and volunteering' do
      let(:event) { create(:event) }

      before do
        create(:result, athlete:, activity_params: { event: })
        create(:volunteer, athlete:, activity_params: { event: })

        get total_events_athlete_statistics_url(athlete_id: athlete.id)
      end

      it 'links event names to event pages' do
        event_href = event_path(event.code_name)

        expect(response.body).to include(event.name)
        expect(response.body.scan(%(href="#{event_href}")).size).to eq(2)
      end
    end
  end

  describe 'GET /total_trophies' do
    it 'renders a successful response' do
      get total_trophies_athlete_statistics_url(athlete_id: athlete.id)
      expect(response).to be_successful
    end
  end

  describe 'GET /goals' do
    it 'renders a successful response' do
      get goals_athlete_statistics_url(athlete_id: athlete.id)
      expect(response).to be_successful
    end
  end

  describe 'GET /followers' do
    it 'renders a successful response' do
      get followers_athlete_statistics_url(athlete_id: athlete.id)
      expect(response).to be_successful
    end
  end

  describe 'GET /friends' do
    it 'renders a successful response' do
      get friends_athlete_statistics_url(athlete_id: athlete.id)
      expect(response).to be_successful
    end
  end

  describe 'GET /volunteering_chart' do
    it 'renders a successful response' do
      get volunteering_chart_athlete_statistics_url(athlete_id: athlete.id)
      expect(response).to be_successful
    end
  end
end
