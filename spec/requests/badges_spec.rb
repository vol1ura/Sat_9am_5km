RSpec.describe '/badges', type: :request do
  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :badge, 3
      get badges_url
      expect(response).to be_successful
    end
  end
end
