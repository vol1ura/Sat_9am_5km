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
      before { sign_in create(:user, :with_athlete) }

      it 'renders root page with successful response' do
        get root_url
        expect(response).to be_successful
      end
    end
  end

  describe 'POST /submit_feedback' do
    let(:message) { 'a' * 2000 }

    before do
      allow(NotificationMailer).to receive_message_chain(:with, :feedback, :deliver_later) # rubocop:disable RSpec/MessageChain
      post submit_feedback_pages_url, params: { message: }
    end

    context 'when message is valid' do
      it 'sends feedback and redirects with notice' do
        expect(NotificationMailer).to have_received(:with).with(hash_including(message:)).once
        expect(response).to redirect_to(page_path(page: 'feedback'))
        follow_redirect!
        expect(response.body).to include(I18n.t('pages.submit_feedback.sent'))
      end
    end

    context 'when message is too long' do
      let(:message) { 'a' * 2001 }

      it 'does not send feedback and redirects with alert' do
        expect(NotificationMailer).not_to have_received(:with)
        expect(response).to redirect_to(page_path(page: 'feedback'))
        follow_redirect!
        expect(response.body).to include(I18n.t('pages.submit_feedback.error'))
      end
    end
  end

  describe 'GET /app' do
    it 'sends app file' do
      get app_pages_url
      expect(response).to be_successful
    end
  end
end
