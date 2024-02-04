# frozen_string_literal: true

RSpec.describe '/pages' do
  describe 'GET /pages' do
    %w[index about support rules].each do |page|
      it "renders page #{page} with successful response", vcr: page == 'about' do
        get page_url(page:)
        expect(response).to be_successful
      end
    end

    it 'renders 404 error page' do
      get page_url(page: 'test')
      expect(response).to have_http_status :not_found
    end

    context 'when user log in' do
      before do
        user = create(:user)
        create(:athlete, user_id: user.id)
        sign_in user
      end

      it 'renders root page with successful response' do
        get root_url
        expect(response).to be_successful
      end
    end
  end
end
