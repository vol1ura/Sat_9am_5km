RSpec.describe '/badges', type: :request do
  describe 'GET /badges' do
    it 'renders a successful response' do
      create_list :badge, 3
      get badges_url
      expect(response).to be_successful
    end
  end

  describe 'GET /badges/1' do
    it 'renders a successful response' do
      badge = create :badge
      create_list :trophy, 3, badge: badge
      get badge_url(badge)
      expect(response).to be_successful
    end
  end
end
