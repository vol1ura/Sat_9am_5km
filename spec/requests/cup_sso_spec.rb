# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/cup_credentials'

RSpec.describe 'GET /cup_sso' do
  include CupCredentials

  let(:state) { 'a' * 32 }
  let(:callback) { 'http://127.0.0.1:8080/api/v1/auth/s95/callback' }
  let(:user) { create(:user, :with_athlete) }

  before { stub_cup_credentials }

  context 'when the visitor is signed in' do
    before { sign_in user }

    it 'redirects to the exact cup callback with a signed token' do
      get cup_sso_path, params: { return_to: callback, state: state }

      expect(response).to have_http_status(:found)
      location = URI(response.headers['Location'])
      expect(location.host).to eq('127.0.0.1')
      expect(location.path).to eq(Cup::CallbackUrl::PATH)
      expect(signed_payload(location)['athlete_id']).to eq(user.athlete.id)
    end

    it 'allows only the production host over https' do
      target = 'https://cup.s95.ru/api/v1/auth/s95/callback'
      get cup_sso_path, params: { return_to: target, state: state }

      expect(response).to redirect_to(production_callback)
    end

    it 'does not write to the database' do
      expect { get cup_sso_path, params: { return_to: callback, state: state } }.not_to change(Athlete, :count)
    end

    it 'rejects a lookalike host' do
      get cup_sso_path, params: { return_to: 'https://cup.s95.ru.evil.test/api/v1/auth/s95/callback', state: state }

      expect(response).to have_http_status(:bad_request)
    end

    it 'rejects a subdomain of the public host' do
      get cup_sso_path, params: { return_to: 'https://evil.cup.s95.ru/api/v1/auth/s95/callback', state: state }

      expect(response).to have_http_status(:bad_request)
    end

    it 'rejects plain http on the public host' do
      get cup_sso_path, params: { return_to: 'http://cup.s95.ru/api/v1/auth/s95/callback', state: state }

      expect(response).to have_http_status(:bad_request)
    end

    it 'sends a user without an athlete back home' do
      sign_in create(:user)
      get cup_sso_path, params: { return_to: callback, state: state }

      expect(response).to redirect_to(root_path)
    end
  end

  it 'sends a guest to the S95 login' do
    get cup_sso_path, params: { return_to: callback, state: state }

    expect(response).to redirect_to(new_user_session_path)
  end

  def production_callback
    @production_callback ||= %r{\Ahttps://cup\.s95\.ru/api/v1/auth/s95/callback\?}
  end

  def signed_payload(location)
    token = Rack::Utils.parse_query(location.query).fetch('token')
    outer = JSON.parse(Base64.urlsafe_decode64(token))
    digest = OpenSSL::HMAC.digest('SHA256', CupCredentials::SECRET, outer.fetch('p'))
    expect(outer.fetch('s')).to eq(Base64.urlsafe_encode64(digest, padding: false))
    JSON.parse(Base64.urlsafe_decode64(outer.fetch('p')))
  end
end
