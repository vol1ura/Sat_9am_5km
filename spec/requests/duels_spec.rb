# frozen_string_literal: true

RSpec.describe '/duels' do
  let(:user) { create(:user) }

  before { sign_in user, scope: :user }

  describe 'GET /duels' do
    let(:athlete) { create(:athlete, user:) }

    before { create_list(:friendship, 2, athlete:) }

    it 'renders a successful response' do
      get duels_url
      expect(response).to be_successful
    end
  end

  describe 'GET /duels/:id' do
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

  describe 'GET /duels/protocol' do
    let(:athlete) { create(:athlete, user:) }
    let(:friend) { create(:athlete) }
    let(:stranger) { create(:athlete) }
    let(:target_date) { Date.new(2024, 8, 3) }
    let(:activity) { create(:activity, date: target_date) }

    before do
      create(:friendship, athlete:, friend:)
      create(:result, athlete:, activity:)
      create(:result, athlete: friend, activity: activity)
      create(:result, athlete: stranger, activity: activity)
      create(:volunteer, athlete: friend, activity: activity, role: :timer)
    end

    it 'shows friends protocol for target saturday only' do
      travel_to target_date do
        get protocol_duels_path
      end

      expect(response).to be_successful
      expect(response.body).to include athlete.name, friend.name, activity.event.name
      expect(response.body).to include 'Секундомер'
      expect(response.body).not_to include stranger.name
    end
  end
end
