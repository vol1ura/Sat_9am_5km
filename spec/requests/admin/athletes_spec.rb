RSpec.describe '/admin/athletes', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :athlete, 3
      get admin_athletes_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      athlete = create :athlete
      get admin_athlete_url(athlete)
      expect(response).to be_successful
    end
  end
end
