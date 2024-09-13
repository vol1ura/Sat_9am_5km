# frozen_string_literal: true

RSpec.describe '/admin/dashboard' do
  describe 'GET /admin' do
    let(:user) { create(:user) }

    before do
      create_list(:activity, 3, published: false, date: Date.current)
      create(:activity, date: Faker::Date.between(from: Date.current, to: Date.current.sunday), published: false)

      sign_in user
    end

    it 'redirects to main page' do
      get admin_dashboard_url
      expect(response).to redirect_to(root_url)
    end

    context 'when user has some permissions' do
      it 'renders a successful response' do
        create(:permission, user:)
        get admin_dashboard_url
        expect(response).to be_successful
      end
    end
  end
end
