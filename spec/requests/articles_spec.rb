# frozen_string_literal: true

RSpec.describe '/articles' do
  describe 'GET /articles' do
    it 'returns http success' do
      get articles_url
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /articles/:page' do
    it 'returns http success' do
      get article_url(page: 'first-run')
      expect(response).to have_http_status(:success)
    end
  end
end
