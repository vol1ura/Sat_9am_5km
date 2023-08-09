RSpec.describe '/admin/dashboard' do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /admin' do
    it 'renders a successful response' do
      create_list(:activity, 3, published: true)
      create(:activity, date: Faker::Date.between(from: Date.current, to: Date.current.sunday))
      get admin_dashboard_url
      expect(response).to be_successful
    end
  end
end
