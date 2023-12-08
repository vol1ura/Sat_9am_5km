RSpec.describe '/api/internal/badges' do
  describe 'POST /api/internal/badges/refresh_home_badges' do
    before { allow(HomeBadgeAwardingJob).to receive(:perform_later) }

    it 'renders successful response' do
      post api_internal_badges_refresh_home_badges_url, headers: { 'Accept' => 'application/json' }

      expect(HomeBadgeAwardingJob).to have_received(:perform_later).once
      expect(response).to be_successful
    end
  end
end
