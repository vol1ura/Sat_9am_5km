# frozen_string_literal: true

RSpec.describe '/admin/clubs' do
  let(:user) { create(:user, :admin) }

  before { sign_in user }

  describe 'GET /admin/clubs' do
    it 'renders a successful response' do
      create_list(:club, 3)
      get admin_clubs_url
      expect(response).to be_successful
    end

    it 'filters names case-insensitively' do
      create(:club, name: 'Moscow RUNNERS')
      create(:club, name: 'Saint Petersburg RUNNERS')

      get admin_clubs_url, params: { q: { name_i_cont: 'moscow' } }

      expect(response.body).to include 'Moscow RUNNERS'
      expect(response.body).not_to include 'Saint Petersburg RUNNERS'
    end
  end

  describe 'POST /admin/clubs' do
    let(:valid_attributes) do
      {
        club: {
          name: Faker::Team.name,
          slug: Faker::Alphanumeric.alphanumeric(number: 3),
          country_id: countries(:ru).id,
        },
      }
    end

    it 'creates a new club' do
      expect do
        post admin_clubs_url, params: valid_attributes
      end.to change(Club, :count).by(1)
    end
  end
end
