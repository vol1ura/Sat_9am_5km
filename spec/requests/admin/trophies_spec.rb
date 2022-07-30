RSpec.describe '/admin/trophies', type: :request do
  let(:user) { create :user }
  let(:badge) { create :badge }

  before do
    sign_in user
  end

  describe 'GET /admin/trophies' do
    it 'renders a successful response' do
      create_list :trophy, 3, badge: badge
      get admin_badge_trophies_url(badge)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/trophies/1' do
    it 'renders a successful response' do
      trophy = create :trophy, badge: badge
      get admin_badge_trophy_url(badge, trophy)
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/trophies/1/edit' do
    context 'when user is not authorized' do
      it 'redirects to root url' do
        trophy = create :trophy, badge: badge
        get edit_admin_badge_trophy_url(badge, trophy)
        expect(response).to have_http_status :found
        expect(response).to redirect_to(admin_root_url)
      end
    end

    context 'when user is admin' do
      before do
        user.admin!
      end

      it 'renders form' do
        trophy = create :trophy, badge: badge
        get edit_admin_badge_trophy_url(badge, trophy)
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /admin/trophies' do
    before do
      user.admin!
    end

    let(:athlete) { create :athlete }
    let(:valid_attributes) do
      {
        trophy: {
          badge_id: badge.id,
          athlete_id: athlete.id
        }
      }
    end

    it 'creates a new trophy' do
      expect do
        post admin_badge_trophies_url(badge), params: valid_attributes
      end.to change(Trophy, :count).by(1)
    end
  end
end
