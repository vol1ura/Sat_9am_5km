RSpec.describe '/admin/badges', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :badge, 3
      get admin_badges_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      badge = create :badge
      get admin_badge_url(badge)
      expect(response).to be_successful
    end
  end
end
