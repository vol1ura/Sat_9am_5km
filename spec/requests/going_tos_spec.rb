# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/going_tos' do
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let!(:athlete) { create(:athlete, user:) }

  before { sign_in user, scope: :user }

  describe 'POST /going_tos' do
    it 'returns a successful response' do
      allow(athlete).to receive(:update).with(going_to_event: event).and_return(true)

      post event_going_to_url(event.code_name), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'DELETE /going_tos' do
    it 'returns a successful response' do
      delete event_going_to_url(event.code_name), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
    end
  end
end
