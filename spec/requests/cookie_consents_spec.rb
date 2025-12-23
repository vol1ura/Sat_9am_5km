# frozen_string_literal: true

RSpec.describe '/cookie_consent' do
  describe 'POST /cookie_consent' do
    it 'sets cookie and redirects to root' do
      post cookie_consent_url

      expect(cookies[:policy_accepted]).to eq 'true'
      expect(response).to redirect_to root_path
    end

    context 'when user is logged in' do
      let(:user) { create(:user, policy_accepted: false) }

      before { sign_in user }

      it 'updates user flag and sets cookie' do
        post cookie_consent_url

        expect(user.reload.policy_accepted).to be true
        expect(cookies[:policy_accepted]).to eq 'true'
        expect(response).to redirect_to root_path
      end
    end

    context 'when request is in Turbo Stream format' do
      it 'returns stream to hide banner and sets cookie' do
        post cookie_consent_url, as: :turbo_stream

        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.body).to include '<turbo-stream action="remove" target="cookie-consent">'
        expect(cookies[:policy_accepted]).to eq 'true'
      end
    end
  end
end
