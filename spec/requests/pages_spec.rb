RSpec.describe '/pages' do
  describe 'GET /pages' do
    before do
      srand(1000)
    end

    %w[index about support rules].each do |page|
      it "renders page #{page} with successful response", vcr: page == 'about' do
        get page_url(page: page)
        expect(response).to be_successful
      end
    end
  end
end
