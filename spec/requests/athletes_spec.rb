RSpec.describe '/athletes', type: :request do
  describe 'GET /index' do
    it 'renders a successful response for name search' do
      create :athlete, name: 'SOME Test'
      create_list :athlete, 3
      get athletes_url(name: 'Some')
      expect(response).to be_successful
    end

    it 'renders a successful response for ID search' do
      create :athlete, parkrun_code: 111_111
      create_list :athlete, 3
      get athletes_url(name: 111_111)
      expect(response).to be_successful
    end

    it 'renders a successful response for blank search' do
      create_list :athlete, 3
      get athletes_url(name: ' ')
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
