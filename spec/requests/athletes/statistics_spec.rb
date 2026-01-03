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
    before do
      get total_results_athlete_statistics_url(athlete_id: athlete.id)
    end

    it { expect(response).to be_successful }
  end

  describe 'GET /total_events' do
    before do
      get total_events_athlete_statistics_url(athlete_id: athlete.id)
    end

    it { expect(response).to be_successful }
  end

  describe 'GET /total_trophies' do
    before do
      get total_trophies_athlete_statistics_url(athlete_id: athlete.id)
    end

    it { expect(response).to be_successful }
  end

  describe 'GET /followers' do
    before do
      get followers_athlete_statistics_url(athlete_id: athlete.id)
    end

    it { expect(response).to be_successful }
  end

  describe 'GET /friends' do
    before do
      get friends_athlete_statistics_url(athlete_id: athlete.id)
    end

    it { expect(response).to be_successful }
  end

  describe 'GET /best_position_absolute' do
    before do
      get best_position_absolute_athlete_statistics_url(athlete_id: athlete.id)
    end

    it { expect(response).to be_successful }
  end

  describe 'GET /volunteering_chart' do
    before do
      get volunteering_chart_athlete_statistics_url(athlete_id: athlete.id)
    end

    it { expect(response).to be_successful }
  end
end
