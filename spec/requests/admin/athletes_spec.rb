RSpec.describe '/admin/athletes', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      create_list :athlete, 3
      get admin_athletes_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      athlete = create :athlete
      create_list :volunteer, 3, :with_published_activity, athlete: athlete
      get admin_athlete_url(athlete)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/athletes/batch_action' do
    before do
      user.admin!
      Bullet.unused_eager_loading_enable = false
    end

    after do
      Bullet.unused_eager_loading_enable = true
    end

    context 'with valid athletes' do
      let(:athletes) { create_list :athlete, 2, name: 'Same Name', male: true }
      let(:valid_attributes) do
        { batch_action: :reunite, batch_action_inputs: '{}', collection_selection: athletes.map(&:id) }
      end

      it 'redirects to duplicates page' do
        post batch_action_admin_athletes_url, params: valid_attributes
        expect(response).to redirect_to find_duplicates_admin_athletes_path
      end
    end

    context 'with invalid attributes' do
      let(:invalid_attributes) do
        { batch_action: :reunite, batch_action_inputs: {}, collection_selection: [] }
      end

      it 'redirects to admin athletes page' do
        post batch_action_admin_athletes_url, params: invalid_attributes
        expect(response).to redirect_to admin_athletes_path
      end
    end
  end

  describe 'POST /admin/athletes' do
    before do
      user.admin!
    end

    let(:result) { create :result, athlete: nil }
    let(:valid_attributes) do
      {
        athlete: {
          name: Faker::Name.name,
          result_id: result.id
        }
      }
    end

    it 'creates a new contact' do
      expect do
        post admin_athletes_url, params: valid_attributes
      end.to change(Athlete, :count).by(1)
      expect(result.reload.athlete).to be_present
    end
  end
end
