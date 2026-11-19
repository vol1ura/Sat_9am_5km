# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/cup_credentials'

RSpec.describe '/api/cup/athletes' do
  include CupCredentials

  let(:headers) { { 'Authorization' => "Bearer #{CupCredentials::KEY}" } }
  let(:event) { create(:event, name: 'Ангарские пруды', code_name: 'angarskieprudy') }
  let(:club) { create(:club, name: 'Wake&Run') }
  let!(:athlete) do
    create(:athlete, name: 'Анна Кубкова', gender: :female, event: event, club: club, stats: {})
  end

  before { stub_cup_credentials }

  describe 'GET /api/cup/athletes/search' do
    it 'rejects a missing key' do
      get '/api/cup/athletes/search', params: { q: 'Кубкова' }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'fails closed when the api key is blank' do
      stub_cup_credentials(api_key: '')
      get '/api/cup/athletes/search', params: { q: 'Кубкова' }, headers: headers

      expect(response).to have_http_status(:service_unavailable)
    end

    it 'finds an athlete by name without extra queries per row' do
      get '/api/cup/athletes/search', params: { q: 'Кубкова' }, headers: headers

      expect(response).to have_http_status(:ok)
      row = response.parsed_body.fetch('athletes').find { |item| item['id'] == athlete.id }
      expect(row).to include('home_event_code' => 'angarskieprudy', 'club_name' => 'Wake&Run', 'runs_count' => 0)
    end

    it 'finds an athlete by the S95 personal code' do
      code = Athlete::SAT_9AM_5KM_BORDER + athlete.id
      get '/api/cup/athletes/search', params: { q: code.to_s }, headers: headers

      expect(response.parsed_body.fetch('athletes').pluck('id')).to eq([athlete.id])
    end

    it 'caps the result at the search limit' do
      stub_const('API::Cup::AthletesController::MAX_SEARCH', 1)
      create(:athlete, name: 'Кубков Уникальный')
      create(:athlete, name: 'Кубков Уникальный Второй')
      get '/api/cup/athletes/search', params: { q: 'Уникальный' }, headers: headers

      expect(response.parsed_body.fetch('athletes').size).to eq(1)
    end

    it 'counts only published volunteering on main roles when there are no runs' do
      dates = Array.new(6) { |index| Date.new(2026, 1, index + 1) }
      dates.first(4).each { |date| create(:volunteer, athlete: athlete, role: :marshal, activity_params: { date: }) }
      create(:volunteer, athlete: athlete, role: :other, activity_params: { date: dates[4] })
      create(:volunteer, athlete: athlete, role: :timer, activity_params: { date: dates[5], published: false })

      code = Athlete::SAT_9AM_5KM_BORDER + athlete.id
      get '/api/cup/athletes/search', params: { q: code.to_s }, headers: headers

      row = response.parsed_body.fetch('athletes').sole
      expect(row).to include('id' => athlete.id, 'volunteering_count' => 4)
    end

    it 'uses the stored stats when the athlete already has runs' do
      athlete.update!(stats: { 'results' => { 'count' => 2 }, 'volunteers' => { 'count' => 9 } })
      create(:volunteer, athlete: athlete, role: :marshal)

      code = Athlete::SAT_9AM_5KM_BORDER + athlete.id
      get '/api/cup/athletes/search', params: { q: code.to_s }, headers: headers

      expect(response.parsed_body.fetch('athletes').sole).to include('runs_count' => 2, 'volunteering_count' => 9)
    end

    it 'does not insert rows' do
      expect do
        get '/api/cup/athletes/search', params: { q: 'Кубкова' }, headers: headers
      end.not_to change(Athlete, :count)
    end
  end
end
