RSpec.describe '/admin/results', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :result, 3
      get admin_results_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      result = create :result
      get admin_result_url(result)
      expect(response).to be_successful
    end
  end
end
