# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /cup/authorize' do
  let(:sso_secret) { 's' * 32 }
  let(:state) { 'a' * 32 }
  let(:user) { create(:user, :with_athlete) }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:cup, :sso_secret).and_return(sso_secret)
    host! 's95.ru'
  end

  context 'when the visitor is signed in' do
    before { sign_in user }

    it 'redirects to cup.s95.ru' do
      get cup_authorize_path, params: { state: }

      expect(response).to have_http_status(:found)
      location = URI(response.headers['Location'])
      expect(location.host).to eq('cup.s95.ru')
      expect(location.path).to eq(CupController::CALLBACK_PATH)
    end

    it 'puts athlete_id in the signed token without admin flags' do
      get cup_authorize_path, params: { state: }
      payload = signed_payload(URI(response.headers['Location']))

      expect(payload['athlete_id']).to eq(user.athlete.id)
      expect(payload).not_to include('is_admin', 'athlete_code')
    end

    it 'uses the country-specific cup host on s95.rs' do
      host! 's95.rs'
      get cup_authorize_path, params: { state: }

      expect(URI(response.headers['Location']).host).to eq('cup.s95.rs')
    end

    it 'does not write to the database' do
      expect { get cup_authorize_path, params: { state: } }.not_to change(Athlete, :count)
    end

    it 'sends a user without an athlete back home' do
      sign_in create(:user)
      get cup_authorize_path, params: { state: }

      expect(response).to redirect_to(root_path)
    end
  end

  it 'sends a guest to the S95 login' do
    get cup_authorize_path, params: { state: }

    expect(response).to redirect_to(new_user_session_path)
  end

  context 'when sso is not configured' do
    let(:sso_secret) { '' }

    it 'returns 404' do
      sign_in user
      get cup_authorize_path, params: { state: }

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include('404')
    end
  end

  def signed_payload(location)
    token = Rack::Utils.parse_query(location.query).fetch('token')
    outer = JSON.parse(Base64.urlsafe_decode64(token))
    digest = OpenSSL::HMAC.digest('SHA256', sso_secret, outer.fetch('p'))
    expect(outer.fetch('s')).to eq(Base64.urlsafe_encode64(digest, padding: false))
    JSON.parse(Base64.urlsafe_decode64(outer.fetch('p')))
  end
end
