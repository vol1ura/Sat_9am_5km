RSpec.describe '/admin/clubs' do
  let(:user) { create(:user, :admin) }

  before { sign_in user }

  describe 'GET /admin/clubs' do
    it 'renders a successful response' do
      create_list(:club, 3)
      get admin_clubs_url
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/clubs' do
    let(:valid_attributes) do
      {
        club: {
          name: Faker::Team.name,
          country_id: countries(:ru).id,
        },
      }
    end

    it 'creates a new club' do
      expect do
        post admin_clubs_url, params: valid_attributes
      end.to change(Club, :count).by(1)
    end
  end
end
