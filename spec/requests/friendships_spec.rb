# frozen_string_literal: true

RSpec.describe '/friendships' do
  let(:user) { create(:user) }
  let(:athlete) { create(:athlete, user:) }
  let(:friend) { create(:athlete) }

  before { sign_in user, scope: :user }

  describe 'POST #create' do
    it 'creates a new friendship' do
      expect do
        post friendships_url, params: { friend_id: friend.id }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      end.to change(athlete.friends, :count).by(1)
      expect(response).to be_successful
    end

    context 'when the friend is already a friend' do
      before { athlete.friends << friend }

      it 'does not create a new friendship' do
        expect do
          post friendships_url, params: { friend_id: friend.id }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        end.not_to change(athlete.friends, :count)
      end
    end
  end

  describe 'DELETE /friendships/1' do
    let!(:friendship) { create(:friendship, athlete:, friend:) }

    it 'destroys the friendship' do
      expect do
        delete friendship_url friendship, params: { viewed_athlete_id: friend.id }, format: :turbo_stream
      end.to change(Friendship, :count).by(-1)
      expect(response).to be_successful
    end
  end
end
