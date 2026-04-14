# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/favorite_events' do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  before { sign_in user }

  describe 'PUT /events/:code_name/favorite_event' do
    it 'adds event to favorites via turbo stream' do
      put event_favorite_event_url(event.code_name), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(response.media_type).to eq('text/vnd.turbo-stream.html')
      expect(user.reload.favorite_event_ids).to include(event.id)
    end

    it 'removes event from favorites via turbo stream' do
      user.update!(favorite_event_ids: [event.id])

      put event_favorite_event_url(event.code_name), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }

      expect(response).to have_http_status(:success)
      expect(user.reload.favorite_event_ids).not_to include(event.id)
    end

    it 'redirects when not signed in' do
      sign_out user
      put event_favorite_event_url(event.code_name)

      expect(response).to have_http_status(:redirect)
    end
  end
end
