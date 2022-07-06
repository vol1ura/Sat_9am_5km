RSpec.describe '/admin/volunteers', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe 'GET /admin/volunteers' do
    it 'renders a successful response' do
      create_list :volunteer, 3
      get admin_volunteers_url
      expect(response).to be_successful
    end
  end

  describe 'GET /admin/volunteers/1' do
    it 'renders a successful response' do
      volunteer = create :volunteer
      get admin_volunteer_url(volunteer)
      expect(response).to be_successful
    end
  end

  describe 'POST /admin/volunteers' do
    let(:activity) { create :activity }
    let(:athlete) { create :athlete }
    let(:valid_attributes) do
      {
        parkrun_code: athlete.parkrun_code,
        volunteer: { activity_id: activity.id, role: Volunteer::ROLES.keys.sample }
      }
    end

    it 'redirects unauthorized user' do
      post admin_volunteers_url, params: valid_attributes
      expect(response).to redirect_to(admin_root_url)
    end

    context 'when user is admin' do
      before do
        user.admin!
      end

      it 'creates a new volunteer' do
        expect do
          post admin_volunteers_url, params: valid_attributes
        end.to change(Volunteer, :count).by(1)
      end

      it "redirects to the volunteer's show page" do
        post admin_volunteers_url, params: valid_attributes
        expect(response).to redirect_to(admin_volunteer_url(Volunteer.last))
      end
    end
  end
end
