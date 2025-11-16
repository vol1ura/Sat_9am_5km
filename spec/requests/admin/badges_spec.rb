# frozen_string_literal: true

RSpec.describe '/admin/badges' do
  let(:user) { create(:user, :admin) }

  before { sign_in user, scope: :user }

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

  describe 'POST /admin/badges' do
    let(:badge_params) do
      {
        country_code: 'ru',
        badge: {
          received_date: Date.tomorrow,
          name_translations: { ru: 'test' },
          conditions_translations: { ru: 'test' },
          image: Rack::Test::UploadedFile.new(File.open('spec/fixtures/files/default.png'), 'image/png'),
        },
      }
    end

    it 'renders a successful response' do
      post admin_badges_url, params: badge_params
      badge = Badge.last
      expect(response).to redirect_to admin_badge_url(badge)
      expect(badge.country_code).to eq('ru')
    end
  end
end
