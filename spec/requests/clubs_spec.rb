RSpec.describe '/clubs', type: :request do
  describe 'GET /index' do
    it 'renders a successful response' do
      clubs = create_list :club, 3
      clubs.each { |club| create_list :athlete, 3, club: club }
      get clubs_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      club = create :club
      athletes = create_list :athlete, 3, club: club
      athletes.each { |athlete| create_list :result, 3, athlete: athlete }
      get club_url(club)
      expect(response).to be_successful
    end
  end
end
