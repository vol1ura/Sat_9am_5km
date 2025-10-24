# frozen_string_literal: true

RSpec.describe '/duels' do
  let(:user) { create(:user) }

  before { sign_in user, scope: :user }

  describe 'GET /index' do
    let(:athlete) { create(:athlete, user:) }

    before { create_list(:friendship, 2, athlete:) }

    it 'renders a successful response' do
      get duels_url
      expect(response).to be_successful
    end
  end
end
