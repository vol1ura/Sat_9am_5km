# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/cup_credentials'

RSpec.describe 'GET /api/cup/protocol' do
  include CupCredentials

  let(:headers) { { 'Authorization' => "Bearer #{CupCredentials::KEY}" } }
  let(:event) { create(:event, code_name: 'angarskieprudy') }
  let(:activity) { create(:activity, event: event, date: Date.new(2026, 12, 5), published: true) }
  let(:athlete) { create(:athlete) }

  before do
    stub_cup_credentials
    create(:result, activity: activity, athlete: athlete, position: 1, total_time: 1400)
    create(:result, activity: activity, athlete: nil, position: 2, total_time: nil)
  end

  it 'returns finishers in seconds and skips empty rows' do
    get '/api/cup/protocol', params: { event_code: 'AngarskiePrudy', date: '2026-12-05' }, headers: headers

    expect(response).to have_http_status(:ok)
    body = response.parsed_body
    expect(body).to include('published' => true, 'activity_id' => activity.id)
    expect(body.fetch('results')).to eq([{ 'athlete_id' => athlete.id, 'position' => 1, 'total_time_sec' => 1400 }])
  end

  it 'answers 304 when the protocol is unchanged' do
    activity.update!(updated_at: 1.hour.ago)
    get '/api/cup/protocol',
        params: { event_code: event.code_name, date: '2026-12-05' },
        headers: headers.merge('If-Modified-Since' => Time.current.httpdate)

    expect(response).to have_http_status(:not_modified)
  end

  it 'rejects a bad date and an unpublished activity' do
    get '/api/cup/protocol', params: { event_code: event.code_name, date: 'soon' }, headers: headers
    expect(response).to have_http_status(:bad_request)

    activity.update!(published: false)
    get '/api/cup/protocol', params: { event_code: event.code_name, date: '2026-12-05' }, headers: headers
    expect(response).to have_http_status(:not_found)
  end

  it 'does not write results' do
    expect do
      get '/api/cup/protocol', params: { event_code: event.code_name, date: '2026-12-05' }, headers: headers
    end.not_to change(Result, :count)
  end
end
