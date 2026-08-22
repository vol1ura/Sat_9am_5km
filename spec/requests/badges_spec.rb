# frozen_string_literal: true

RSpec.describe '/badges' do
  describe 'GET /badges' do
    it 'redirects to achievements' do
      get badges_url
      expect(response).to redirect_to(achievements_badges_url)
    end
  end

  describe 'GET /badges/achievements' do
    it 'renders a successful response' do
      create_list(:badge, 3)
      get achievements_badges_url
      expect(response).to be_successful
    end
  end

  describe 'GET /badges/funruns' do
    it 'renders a successful response' do
      create(:badge, kind: :funrun, received_date: 1.year.ago.to_date)
      get funruns_badges_url
      expect(response).to be_successful
    end
  end

  describe 'GET /badges/archive' do
    it 'renders a successful response' do
      create(:badge, kind: :funrun, received_date: 3.years.ago.to_date)
      get archive_badges_url
      expect(response).to be_successful
    end
  end

  describe 'GET /badges/1' do
    it 'renders a successful response' do
      badge = create(:badge)
      create_list(:trophy, 3, badge:)
      get badge_url(badge)
      expect(response).to be_successful
    end
  end
end
