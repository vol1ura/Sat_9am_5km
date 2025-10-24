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

  describe 'GET /show' do
    let(:athlete) { create(:athlete, user:) }
    let(:friend) { create(:athlete) }

    before do
      create(:friendship, athlete:, friend:)
      activity = create(:activity)
      create(:result, activity:, athlete:)
      create(:result, activity: activity, athlete: friend)
    end

    it 'renders a successful response' do
      get duel_path(friend)
      expect(response).to be_successful
    end
  end
end
