RSpec.describe '/admin/utilities' do
  let(:user) { create(:user, :admin) }
  let(:badge) { create(:badge, kind: :funrun) }
  let(:activity) { create(:activity) }

  before { sign_in user }

  describe 'GET /admin/utilities' do
    it 'renders a successful response' do
      get admin_utilities_url
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/utilities/award_funrun_badge' do
    it 'renders a successful response' do
      expect do
        post admin_utilities_award_funrun_badge_url, params: { activity_id: activity.id, badge_id: badge.id }
      end.to have_enqueued_job.on_queue('default').at(:no_wait)
      expect(response).to redirect_to admin_badge_trophies_path(badge.id)
    end
  end
end
