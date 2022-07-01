RSpec.describe '/athletes', type: :request do
  describe 'GET /index' do
    xit 'renders a successful response' do
      create_list :athlete, 3
      get athletes_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      athlete = create :athlete
      get athlete_url(athlete)
      expect(response).to be_successful
    end
  end
end
