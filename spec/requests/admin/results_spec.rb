RSpec.describe '/admin/results', type: :request do
  let(:user) { create :user }
  let(:activity) { create :activity }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :result, 3, activity: activity
      get admin_activity_results_url(activity)
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      result = create :result, activity: activity
      get admin_activity_result_url(activity, result)
      expect(response).to be_successful
    end
  end
end
