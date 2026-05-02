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
    let(:user_contact) { '' }
    let(:policy_accepted) { '1' }

    before do
      allow(NotificationMailer).to receive_message_chain(:with, :feedback, :deliver_later) # rubocop:disable RSpec/MessageChain
      post submit_feedback_pages_url, params: { message:, user_contact:, policy_accepted: }
    end

    context 'when message is valid and policy accepted' do
      it 'sends feedback and redirects with notice' do
        expect(NotificationMailer).to have_received(:with).with(hash_including(message: message, user_contact: nil)).once
        expect(response).to redirect_to(page_path(page: 'feedback'))
        follow_redirect!
        expect(response.body).to include(I18n.t('pages.submit_feedback.sent'))
      end
    end

    context 'when user_contact is provided' do
      let(:user_contact) { '  user@example.com  ' }

      it 'forwards trimmed contact to mailer' do
        expect(NotificationMailer).to have_received(:with).with(hash_including(user_contact: 'user@example.com')).once
      end
    end

    context 'when policy is not accepted' do
      let(:policy_accepted) { '0' }

      it 'does not send feedback and redirects with alert' do
        expect(NotificationMailer).not_to have_received(:with)
        expect(response).to redirect_to(page_path(page: 'feedback'))
        follow_redirect!
        expect(response.body).to include(I18n.t('pages.submit_feedback.policy_required'))
      end
    end

    context 'when policy was already accepted via cookie' do
      let(:policy_accepted) { '0' }

      before do
        cookies[:policy_accepted] = 'true'
        post submit_feedback_pages_url, params: { message:, user_contact: }
      end

      it 'sends feedback without explicit checkbox' do
        expect(NotificationMailer).to have_received(:with).with(hash_including(message:)).once
        expect(response).to redirect_to(page_path(page: 'feedback'))
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
