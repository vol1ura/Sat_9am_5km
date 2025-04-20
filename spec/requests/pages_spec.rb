# frozen_string_literal: true

RSpec.describe '/pages' do
  describe 'GET /pages' do
    %w[about support rules].each do |page|
      it "renders #{page} page with successful response", vcr: page == 'about' do
        get page_url(page:)
        expect(response).to be_successful
      end
    end

    context 'with json request' do
      let!(:activity) { create(:activity) }
      let(:event) { activity.event }

      it 'returns events params' do
        get pages_url, headers: { host: 'test.ru' }, as: :json
        expect(response.parsed_body).to eq(
          'events' => [{
            'active' => true,
            'name' => event.name,
            'place' => event.place,
            'town' => event.town,
            'url' => "http://test.ru/events/#{event.code_name}.json",
          }],
        )
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
