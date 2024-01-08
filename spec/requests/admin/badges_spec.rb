# frozen_string_literal: true

RSpec.describe '/admin/badges' do
  let(:user) { create(:user, :admin) }

  before { sign_in user }

  describe 'GET /admin/badges' do
    it 'renders a successful response' do
      create_list(:badge, 3)
      get admin_badges_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/badges/1' do
    it 'renders a successful response' do
      badge = create(:badge)
      get admin_badge_url(badge)
      expect(response).to be_successful
    end
  end
end
