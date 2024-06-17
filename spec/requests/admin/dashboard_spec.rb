# frozen_string_literal: true

RSpec.describe '/admin/dashboard' do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /admin' do
    it 'renders a successful response' do
      create_list(:activity, 3, published: false, date: Date.current)
      create(:activity, date: Faker::Date.between(from: Date.current, to: Date.current.sunday), published: false)
      get admin_dashboard_url
      expect(response).to be_successful
    end
  end
end
