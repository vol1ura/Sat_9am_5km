# frozen_string_literal: true

RSpec.describe '/api/internal/user' do
  describe 'POST /api/internal/user/auth_link' do
    let(:user) { create(:user) }

    it 'return auth link' do
      expect do
        post auth_link_api_internal_user_url, params: { user_id: user.id, locale: 'ru' }, as: :json
      end.to change { user.reload.auth_token }.from(nil).to(String)
      expect(response).to be_successful
    end
  end
end
