RSpec.describe '/pages', type: :request do
  describe 'GET /pages' do
    it 'renders a successful response' do
      get page_url(page: %w[index about support rules].sample)
      expect(response).to be_successful
    end
  end
end
