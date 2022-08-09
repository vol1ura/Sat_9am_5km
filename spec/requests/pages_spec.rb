RSpec.describe '/pages', type: :request do
  describe 'GET /pages' do
    %w[index about support rules].each do |page|
      it "renders page #{page} with successful response", vcr: page == 'about' do
        get page_url(page: page)
        expect(response).to be_successful
      end
    end
  end
end
